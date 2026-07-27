#!/usr/bin/env python3
import hashlib
import json
import os
import socket
import threading
import time
from copy import deepcopy
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

SERVER_HOST = os.environ.get("MTA_HOST", "127.0.0.1")
SERVER_PORT = int(os.environ.get("MTA_PORT", "22003"))
ASE_PORT = int(os.environ.get("MTA_ASE_PORT", str(SERVER_PORT + 123)))
STATE_PATH = Path(os.environ.get("MTA_TELEMETRY_STATE", "/var/lib/mta-zombie-web/telemetry.json"))
MAX_REQUEST_BYTES = 4 * 1024 * 1024
TELEMETRY_LOCK = threading.Lock()


def read_row(payload, start):
    length = payload[start] - 1
    start += 1
    value = payload[start:start + length].decode("utf-8", errors="replace")
    return start + length, value


def query_mta():
    fields = ["game", "port", "name", "gamemode", "map", "version", "extra", "players", "maxplayers"]
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.settimeout(0.8)
        sock.sendto(b"s", (SERVER_HOST, ASE_PORT))
        payload, _ = sock.recvfrom(16384)

    result = {}
    start = 4
    for field in fields:
        start, value = read_row(payload, start)
        result[field] = value
    return result


def empty_telemetry():
    return {
        "version": 1,
        "generatedAt": 0,
        "receivedAt": 0,
        "server": {"name": "Zombie Mod RPG (2011)", "gameType": "Zombie Mod RPG", "maxPlayers": 100},
        "players": [],
        "zombies": [],
        "vehicles": [],
        "markers": [],
        "safeZones": [],
    }


def load_telemetry():
    try:
        loaded = json.loads(STATE_PATH.read_text(encoding="utf-8"))
        return loaded if isinstance(loaded, dict) else empty_telemetry()
    except (OSError, ValueError):
        return empty_telemetry()


TELEMETRY = load_telemetry()


def save_telemetry(snapshot):
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    temporary = STATE_PATH.with_suffix(".tmp")
    temporary.write_text(json.dumps(snapshot, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    temporary.replace(STATE_PATH)


def validate_snapshot(snapshot):
    if not isinstance(snapshot, dict):
        raise ValueError("JSON body must be an object")
    for field in ("players", "zombies", "vehicles", "markers", "safeZones"):
        if not isinstance(snapshot.get(field), list):
            raise ValueError(f"{field} must be an array")
    if not isinstance(snapshot.get("server"), dict):
        raise ValueError("server must be an object")


def merge_snapshot(incoming):
    global TELEMETRY

    generated_at = int(incoming.get("generatedAt") or time.time())
    previous_by_key = {
        player.get("key"): player
        for player in TELEMETRY.get("players", [])
        if isinstance(player, dict) and player.get("key")
    }
    current_by_key = {}
    merged_players = []

    for raw_player in incoming["players"]:
        if not isinstance(raw_player, dict) or not raw_player.get("key"):
            continue
        player = deepcopy(raw_player)
        player["online"] = True
        player["lastSeen"] = generated_at
        current_by_key[player["key"]] = player
        merged_players.append(player)

    for key, previous in previous_by_key.items():
        if key not in current_by_key:
            offline = deepcopy(previous)
            offline["online"] = False
            offline.setdefault("lastSeen", TELEMETRY.get("generatedAt", generated_at))
            offline["vehicle"] = False
            merged_players.append(offline)

    merged = {
        "version": 1,
        "generatedAt": generated_at,
        "receivedAt": int(time.time()),
        "server": deepcopy(incoming["server"]),
        "players": merged_players,
        "zombies": deepcopy(incoming["zombies"]),
        "vehicles": deepcopy(incoming["vehicles"]),
        "markers": deepcopy(incoming["markers"]),
        "safeZones": deepcopy(incoming["safeZones"]),
    }
    save_telemetry(merged)
    TELEMETRY = merged


def public_telemetry():
    with TELEMETRY_LOCK:
        snapshot = deepcopy(TELEMETRY)

    for player in snapshot.get("players", []):
        account_key = str(player.pop("key", player.get("id", "")))
        player["id"] = "player-" + hashlib.sha256(account_key.encode("utf-8")).hexdigest()[:16]

    snapshot["stale"] = int(time.time()) - int(snapshot.get("receivedAt") or 0) > 15
    return snapshot


class Handler(BaseHTTPRequestHandler):
    def send_cors_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def send_json(self, status, body):
        payload = json.dumps(body, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        self.send_response(status)
        self.send_cors_headers()
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_cors_headers()
        self.send_header("Cache-Control", "no-store")
        self.end_headers()

    def do_GET(self):
        path = urlsplit(self.path).path
        if path == "/api/telemetry":
            self.send_json(200, public_telemetry())
            return
        if path not in ("/api/status", "/health"):
            self.send_error(404)
            return

        body = {"online": False, "players": 0, "maxplayers": 100}
        try:
            status = query_mta()
            body.update({
                "online": True,
                "name": status.get("name"),
                "gamemode": status.get("gamemode"),
                "map": status.get("map"),
                "version": status.get("version"),
                "players": int(status.get("players") or 0),
                "maxplayers": int(status.get("maxplayers") or 100),
            })
        except (OSError, ValueError, IndexError) as exc:
            body["error"] = str(exc)
        self.send_json(200, body)

    def do_POST(self):
        if urlsplit(self.path).path != "/api/telemetry":
            self.send_error(404)
            return
        if self.client_address[0] not in ("127.0.0.1", "::1"):
            self.send_error(403)
            return

        try:
            content_length = int(self.headers.get("Content-Length", "0"))
            if content_length <= 0 or content_length > MAX_REQUEST_BYTES:
                raise ValueError("invalid request size")
            incoming = json.loads(self.rfile.read(content_length))
            if isinstance(incoming, list) and len(incoming) == 1 and isinstance(incoming[0], dict):
                incoming = incoming[0]
            validate_snapshot(incoming)
            with TELEMETRY_LOCK:
                merge_snapshot(incoming)
        except (OSError, ValueError, json.JSONDecodeError) as exc:
            print(f"Rejected telemetry snapshot: {exc}", flush=True)
            self.send_json(400, {"ok": False, "error": str(exc)})
            return

        self.send_json(200, {"ok": True})

    def log_message(self, fmt, *args):
        return


if __name__ == "__main__":
    port = int(os.environ.get("MTA_WEB_API_PORT", "8080"))
    ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()

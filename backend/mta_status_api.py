#!/usr/bin/env python3
import json
import os
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

SERVER_HOST = os.environ.get("MTA_HOST", "127.0.0.1")
SERVER_PORT = int(os.environ.get("MTA_PORT", "22003"))
ASE_PORT = int(os.environ.get("MTA_ASE_PORT", str(SERVER_PORT + 123)))
LOG_PATH = Path(os.environ.get("MTA_LOG", "/opt/mta-zombie-rpg/mods/deathmatch/logs/server.log"))


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


def recent_events(limit=18):
    if not LOG_PATH.exists():
        return []
    lines = LOG_PATH.read_text(errors="replace").splitlines()
    return [line for line in lines[-limit:] if line.strip()]


class Handler(BaseHTTPRequestHandler):
    def send_cors_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_cors_headers()
        self.send_header("Cache-Control", "no-store")
        self.end_headers()

    def do_GET(self):
        if self.path not in ("/api/status", "/health"):
            self.send_error(404)
            return

        body = {"online": False, "players": 0, "maxplayers": 100, "events": recent_events()}
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
        except Exception as exc:
            body["error"] = str(exc)

        payload = json.dumps(body, ensure_ascii=False).encode("utf-8")
        self.send_response(200)
        self.send_cors_headers()
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, fmt, *args):
        return


if __name__ == "__main__":
    port = int(os.environ.get("MTA_WEB_API_PORT", "8080"))
    ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()

#!/usr/bin/env python3
import hashlib
import json
import math
import os
import re
import secrets
import socket
import sqlite3
import threading
import time
from contextlib import contextmanager
from copy import deepcopy
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

SERVER_HOST = os.environ.get("MTA_HOST", "127.0.0.1")
SERVER_PORT = int(os.environ.get("MTA_PORT", "22003"))
ASE_PORT = int(os.environ.get("MTA_ASE_PORT", str(SERVER_PORT + 123)))
STATE_PATH = Path(os.environ.get("MTA_TELEMETRY_STATE", "/var/lib/mta-zombie-web/telemetry.json"))
DATABASE_PATH = Path(os.environ.get("MTA_WEB_DATABASE", "/var/lib/mta-zombie-web/auth.db"))
MAX_REQUEST_BYTES = 4 * 1024 * 1024
SESSION_TTL = 24 * 60 * 60
AUTH_TIMEOUT = 14
ACTION_TYPES = {
    "artillery": {"label": "Artillery strike", "cost": 50},
    "airstrike": {"label": "Airstrike", "cost": 75},
}
ALLOWED_ORIGINS = {
    "https://mta.ghostbe.site",
    "https://solpadoin.github.io",
}
USERNAME_PATTERN = re.compile(r"^[A-Za-z0-9_.-]{1,32}$")

TELEMETRY_LOCK = threading.Lock()
DATABASE_LOCK = threading.Lock()
AUTH_CONDITION = threading.Condition()
AUTH_REQUESTS = {}
LOGIN_ATTEMPTS = {}


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
    if "accounts" in snapshot and not isinstance(snapshot["accounts"], list):
        raise ValueError("accounts must be an array")


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


@contextmanager
def database():
    connection = sqlite3.connect(DATABASE_PATH, timeout=10)
    connection.row_factory = sqlite3.Row
    try:
        yield connection
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()


def init_database():
    DATABASE_PATH.parent.mkdir(parents=True, exist_ok=True)
    with DATABASE_LOCK, database() as connection:
        connection.executescript(
            """
            PRAGMA journal_mode=WAL;
            CREATE TABLE IF NOT EXISTS sessions (
                token_hash TEXT PRIMARY KEY,
                username TEXT NOT NULL COLLATE NOCASE,
                created_at INTEGER NOT NULL,
                expires_at INTEGER NOT NULL
            );
            CREATE INDEX IF NOT EXISTS sessions_username_idx ON sessions(username);
            CREATE TABLE IF NOT EXISTS balances (
                username TEXT PRIMARY KEY COLLATE NOCASE,
                materials INTEGER NOT NULL DEFAULT 0,
                updated_at INTEGER NOT NULL
            );
            CREATE TABLE IF NOT EXISTS actions (
                id TEXT PRIMARY KEY,
                username TEXT NOT NULL COLLATE NOCASE,
                action_type TEXT NOT NULL,
                x REAL NOT NULL,
                y REAL NOT NULL,
                cost INTEGER NOT NULL,
                status TEXT NOT NULL,
                message TEXT,
                created_at INTEGER NOT NULL,
                dispatched_at INTEGER,
                completed_at INTEGER
            );
            CREATE INDEX IF NOT EXISTS actions_user_idx ON actions(username, created_at DESC);
            """
        )


def token_hash(token):
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def update_balance(username, materials):
    materials = max(0, min(int(materials), 2_000_000_000))
    with DATABASE_LOCK, database() as connection:
        connection.execute(
            """
            INSERT INTO balances (username, materials, updated_at)
            VALUES (?, ?, ?)
            ON CONFLICT(username) DO UPDATE SET
                materials = excluded.materials,
                updated_at = excluded.updated_at
            """,
            (username, materials, int(time.time())),
        )


def merge_account_balances(accounts):
    for item in accounts:
        if not isinstance(item, dict) or not USERNAME_PATTERN.fullmatch(str(item.get("username", ""))):
            continue
        try:
            update_balance(str(item["username"]), int(item.get("materials") or 0))
        except (TypeError, ValueError):
            continue


def create_session(username, materials):
    token = secrets.token_urlsafe(32)
    now = int(time.time())
    update_balance(username, materials)
    with DATABASE_LOCK, database() as connection:
        connection.execute("DELETE FROM sessions WHERE expires_at <= ?", (now,))
        connection.execute(
            "INSERT INTO sessions (token_hash, username, created_at, expires_at) VALUES (?, ?, ?, ?)",
            (token_hash(token), username, now, now + SESSION_TTL),
        )
    return token


def session_user(authorization):
    if not authorization or not authorization.startswith("Bearer "):
        return None
    token = authorization[7:].strip()
    if not token:
        return None

    now = int(time.time())
    with DATABASE_LOCK, database() as connection:
        row = connection.execute(
            """
            SELECT sessions.username, sessions.expires_at,
                   COALESCE(balances.materials, 0) AS materials,
                   COALESCE(balances.updated_at, 0) AS balance_updated_at
            FROM sessions
            LEFT JOIN balances ON balances.username = sessions.username
            WHERE sessions.token_hash = ?
            """,
            (token_hash(token),),
        ).fetchone()
        if row and int(row["expires_at"]) <= now:
            connection.execute("DELETE FROM sessions WHERE token_hash = ?", (token_hash(token),))
            return None
    return dict(row) if row else None


def delete_session(authorization):
    if not authorization or not authorization.startswith("Bearer "):
        return
    token = authorization[7:].strip()
    with DATABASE_LOCK, database() as connection:
        connection.execute("DELETE FROM sessions WHERE token_hash = ?", (token_hash(token),))


def active_account_names():
    now = int(time.time())
    with DATABASE_LOCK, database() as connection:
        rows = connection.execute(
            "SELECT DISTINCT username FROM sessions WHERE expires_at > ? ORDER BY username",
            (now,),
        ).fetchall()
    return [row["username"] for row in rows]


def login_rate_limited(address):
    now = time.time()
    attempts = [stamp for stamp in LOGIN_ATTEMPTS.get(address, []) if now - stamp < 600]
    LOGIN_ATTEMPTS[address] = attempts
    return len(attempts) >= 5


def record_failed_login(address):
    LOGIN_ATTEMPTS.setdefault(address, []).append(time.time())


def authenticate_with_mta(username, password):
    request_id = secrets.token_urlsafe(12)
    request = {
        "id": request_id,
        "username": username,
        "password": password,
        "created": time.time(),
        "claimed": 0,
        "result": None,
    }
    with AUTH_CONDITION:
        AUTH_REQUESTS[request_id] = request
        AUTH_CONDITION.notify_all()
        deadline = time.time() + AUTH_TIMEOUT
        while request["result"] is None and time.time() < deadline:
            AUTH_CONDITION.wait(timeout=max(0.05, deadline - time.time()))
        result = request["result"]
        request["password"] = None
        AUTH_REQUESTS.pop(request_id, None)
    return result


def claim_auth_requests():
    now = time.time()
    claimed = []
    with AUTH_CONDITION:
        for request in AUTH_REQUESTS.values():
            if request["result"] is not None:
                continue
            if request["claimed"] and now - request["claimed"] < 8:
                continue
            request["claimed"] = now
            claimed.append({
                "id": request["id"],
                "username": request["username"],
                "password": request["password"],
            })
            if len(claimed) >= 5:
                break
    return claimed


def complete_auth_request(payload):
    request_id = str(payload.get("id", ""))
    with AUTH_CONDITION:
        request = AUTH_REQUESTS.get(request_id)
        if not request:
            return
        request["result"] = {
            "success": payload.get("success") is True,
            "username": str(payload.get("username") or request["username"]),
            "materials": int(payload.get("materials") or 0),
        }
        AUTH_CONDITION.notify_all()


def serialize_action(row):
    return {
        "id": row["id"],
        "type": row["action_type"],
        "label": ACTION_TYPES[row["action_type"]]["label"],
        "x": row["x"],
        "y": row["y"],
        "cost": row["cost"],
        "status": row["status"],
        "message": row["message"],
        "createdAt": row["created_at"],
        "completedAt": row["completed_at"],
    }


def create_action(username, action_type, x, y):
    definition = ACTION_TYPES[action_type]
    now = int(time.time())
    action_id = secrets.token_urlsafe(12)
    with DATABASE_LOCK, database() as connection:
        active = connection.execute(
            """
            SELECT COUNT(*) AS total FROM actions
            WHERE username = ? AND status IN ('queued', 'dispatched')
            """,
            (username,),
        ).fetchone()["total"]
        if active:
            raise ValueError("Wait for your current strike request to finish.")
        recent = connection.execute(
            "SELECT created_at FROM actions WHERE username = ? ORDER BY created_at DESC LIMIT 1",
            (username,),
        ).fetchone()
        if recent and now - int(recent["created_at"]) < 2:
            raise ValueError("Please wait before sending another strike request.")
        connection.execute(
            """
            INSERT INTO actions
                (id, username, action_type, x, y, cost, status, created_at)
            VALUES (?, ?, ?, ?, ?, ?, 'queued', ?)
            """,
            (action_id, username, action_type, x, y, definition["cost"], now),
        )
        row = connection.execute("SELECT * FROM actions WHERE id = ?", (action_id,)).fetchone()
    return serialize_action(row)


def claim_actions():
    now = int(time.time())
    with DATABASE_LOCK, database() as connection:
        rows = connection.execute(
            """
            SELECT * FROM actions
            WHERE status = 'queued'
               OR (status = 'dispatched' AND dispatched_at < ?)
            ORDER BY created_at
            LIMIT 5
            """,
            (now - 30,),
        ).fetchall()
        for row in rows:
            connection.execute(
                "UPDATE actions SET status = 'dispatched', dispatched_at = ? WHERE id = ?",
                (now, row["id"]),
            )
    return [
        {
            "id": row["id"],
            "username": row["username"],
            "type": row["action_type"],
            "x": row["x"],
            "y": row["y"],
            "cost": row["cost"],
        }
        for row in rows
    ]


def complete_action(payload):
    action_id = str(payload.get("id", ""))
    success = payload.get("success") is True
    status = "completed" if success else "failed"
    message = str(payload.get("message") or ("Strike dispatched." if success else "Strike failed."))[:240]
    now = int(time.time())
    with DATABASE_LOCK, database() as connection:
        row = connection.execute("SELECT * FROM actions WHERE id = ?", (action_id,)).fetchone()
        if not row or row["status"] in ("completed", "failed"):
            return
        connection.execute(
            "UPDATE actions SET status = ?, message = ?, completed_at = ? WHERE id = ?",
            (status, message, now, action_id),
        )
    if "materials" in payload:
        update_balance(row["username"], int(payload.get("materials") or 0))


def action_for_user(action_id, username):
    with DATABASE_LOCK, database() as connection:
        row = connection.execute(
            "SELECT * FROM actions WHERE id = ? AND username = ?",
            (action_id, username),
        ).fetchone()
    return serialize_action(row) if row else None


class Handler(BaseHTTPRequestHandler):
    def send_cors_headers(self):
        origin = self.headers.get("Origin")
        if origin in ALLOWED_ORIGINS:
            self.send_header("Access-Control-Allow-Origin", origin)
            self.send_header("Vary", "Origin")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Authorization, Content-Type")

    def send_json(self, status, body):
        payload = json.dumps(body, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        self.send_response(status)
        self.send_cors_headers()
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def read_json(self):
        content_length = int(self.headers.get("Content-Length", "0"))
        if content_length <= 0 or content_length > MAX_REQUEST_BYTES:
            raise ValueError("Invalid request size.")
        payload = json.loads(self.rfile.read(content_length))
        if isinstance(payload, list) and len(payload) == 1 and isinstance(payload[0], dict):
            payload = payload[0]
        if not isinstance(payload, dict):
            raise ValueError("JSON body must be an object.")
        return payload

    def is_local(self):
        return self.client_address[0] in ("127.0.0.1", "::1")

    def client_ip(self):
        return self.headers.get("X-Real-IP") or self.client_address[0]

    def require_session(self):
        user = session_user(self.headers.get("Authorization"))
        if not user:
            self.send_json(401, {"ok": False, "error": "Authentication required."})
        return user

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
        if path == "/api/auth/session":
            user = self.require_session()
            if user:
                self.send_json(200, {
                    "ok": True,
                    "user": {
                        "username": user["username"],
                        "materials": int(user["materials"]),
                    },
                })
            return
        if path.startswith("/api/actions/"):
            user = self.require_session()
            if not user:
                return
            action = action_for_user(path.rsplit("/", 1)[-1], user["username"])
            if not action:
                self.send_json(404, {"ok": False, "error": "Action not found."})
            else:
                self.send_json(200, {"ok": True, "action": action})
            return
        if path not in ("/api/status", "/health"):
            self.send_json(404, {"ok": False, "error": "Not found."})
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
        path = urlsplit(self.path).path
        try:
            payload = self.read_json()
        except (ValueError, json.JSONDecodeError) as exc:
            self.send_json(400, {"ok": False, "error": str(exc)})
            return

        if path == "/api/telemetry":
            self.handle_telemetry(payload)
        elif path == "/api/game/result":
            self.handle_game_result(payload)
        elif path == "/api/auth/login":
            self.handle_login(payload)
        elif path == "/api/auth/logout":
            self.handle_logout()
        elif path == "/api/actions":
            self.handle_action(payload)
        else:
            self.send_json(404, {"ok": False, "error": "Not found."})

    def handle_telemetry(self, incoming):
        if not self.is_local():
            self.send_json(403, {"ok": False, "error": "Forbidden."})
            return
        try:
            validate_snapshot(incoming)
            with TELEMETRY_LOCK:
                merge_snapshot(incoming)
            merge_account_balances(incoming.get("accounts", []))
        except (OSError, ValueError, TypeError) as exc:
            print(f"Rejected telemetry snapshot: {exc}", flush=True)
            self.send_json(400, {"ok": False, "error": str(exc)})
            return

        self.send_json(200, {
            "ok": True,
            "authRequests": claim_auth_requests(),
            "actions": claim_actions(),
            "accounts": active_account_names(),
        })

    def handle_game_result(self, payload):
        if not self.is_local():
            self.send_json(403, {"ok": False, "error": "Forbidden."})
            return
        kind = payload.get("kind")
        if kind == "auth":
            complete_auth_request(payload)
        elif kind == "action":
            complete_action(payload)
        else:
            self.send_json(400, {"ok": False, "error": "Unknown result type."})
            return
        self.send_json(200, {"ok": True})

    def handle_login(self, payload):
        address = self.client_ip()
        if login_rate_limited(address):
            self.send_json(429, {"ok": False, "error": "Too many login attempts. Try again later."})
            return
        username = str(payload.get("username") or "").strip()
        password = str(payload.get("password") or "")
        if not USERNAME_PATTERN.fullmatch(username) or not password or len(password) > 128:
            record_failed_login(address)
            self.send_json(401, {"ok": False, "error": "Invalid username or password."})
            return

        result = authenticate_with_mta(username, password)
        password = None
        if not result or not result["success"]:
            record_failed_login(address)
            status = 503 if result is None else 401
            error = "Game authentication is temporarily unavailable." if result is None else "Invalid username or password."
            self.send_json(status, {"ok": False, "error": error})
            return

        token = create_session(result["username"], result["materials"])
        self.send_json(200, {
            "ok": True,
            "token": token,
            "user": {
                "username": result["username"],
                "materials": result["materials"],
            },
        })

    def handle_logout(self):
        user = self.require_session()
        if not user:
            return
        delete_session(self.headers.get("Authorization"))
        self.send_json(200, {"ok": True})

    def handle_action(self, payload):
        user = self.require_session()
        if not user:
            return
        action_type = str(payload.get("type") or "")
        if action_type not in ACTION_TYPES:
            self.send_json(400, {"ok": False, "error": "Unknown strike type."})
            return
        try:
            x = float(payload.get("x"))
            y = float(payload.get("y"))
        except (TypeError, ValueError):
            self.send_json(400, {"ok": False, "error": "Invalid target coordinates."})
            return
        if not math.isfinite(x) or not math.isfinite(y) or not (-3000 <= x <= 3000 and -3000 <= y <= 3000):
            self.send_json(400, {"ok": False, "error": "Target is outside San Andreas."})
            return

        cost = ACTION_TYPES[action_type]["cost"]
        if int(user["materials"]) < cost:
            self.send_json(409, {"ok": False, "error": "Not enough materials."})
            return
        try:
            action = create_action(user["username"], action_type, round(x, 2), round(y, 2))
        except ValueError as exc:
            self.send_json(409, {"ok": False, "error": str(exc)})
            return
        self.send_json(202, {"ok": True, "action": action})

    def log_message(self, fmt, *args):
        return


if __name__ == "__main__":
    init_database()
    port = int(os.environ.get("MTA_WEB_API_PORT", "8080"))
    ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()

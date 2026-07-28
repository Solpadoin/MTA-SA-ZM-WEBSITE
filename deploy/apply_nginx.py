#!/usr/bin/env python3
import re
import sys
from pathlib import Path

BEGIN = "    # BEGIN ZMRPG TELEMETRY"
END = "    # END ZMRPG TELEMETRY"
FASTDL_BEGIN = "    # BEGIN ZMRPG FASTDL"
FASTDL_END = "    # END ZMRPG FASTDL"
FASTDL_LOCATION = """    location ^~ /mta-download/ {
        alias /opt/mta-zombie-rpg/mods/deathmatch/resource-cache/http-client-files/;
        limit_except GET {
            deny all;
        }
        autoindex off;
        access_log off;
        default_type application/octet-stream;
        gzip on;
        gzip_vary on;
        gzip_comp_level 6;
        gzip_min_length 256;
        gzip_types *;
        sendfile on;
        tcp_nopush on;
        add_header Cache-Control "public, max-age=300" always;
        add_header X-Content-Type-Options "nosniff" always;
    }
"""
BLOCK = (
    """    # BEGIN ZMRPG TELEMETRY
"""
    + FASTDL_LOCATION
    + """    location = /mta/api/events {
        limit_except GET {
            deny all;
        }
        proxy_pass http://127.0.0.1:18080/api/events;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 5s;
    }

    location = /mta/api/telemetry {
        limit_except GET {
            deny all;
        }
        proxy_pass http://127.0.0.1:18080/api/telemetry;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 5s;
    }

    location ^~ /mta/api/auth/ {
        proxy_pass http://127.0.0.1:18080/api/auth/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 20s;
    }

    location = /mta/api/actions {
        proxy_pass http://127.0.0.1:18080/api/actions;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 10s;
    }

    location ^~ /mta/api/actions/ {
        proxy_pass http://127.0.0.1:18080/api/actions/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 10s;
    }
    # END ZMRPG TELEMETRY

"""
)


def apply_api_site(path):
    content = path.read_text(encoding="utf-8")
    content = re.sub(
        rf"{re.escape(BEGIN)}.*?{re.escape(END)}(?:\r?\n){{1,2}}",
        "",
        content,
        flags=re.DOTALL,
    )

    anchor = "    location /mta/health"
    if anchor not in content:
        raise RuntimeError("Expected /mta/health location was not found")
    content = content.replace(anchor, BLOCK + anchor, 1)
    path.write_text(content, encoding="utf-8")


def apply_fastdl_site(path):
    content = path.read_text(encoding="utf-8")
    content = re.sub(
        rf"{re.escape(FASTDL_BEGIN)}.*?{re.escape(FASTDL_END)}(?:\r?\n){{1,2}}",
        "",
        content,
        flags=re.DOTALL,
    )

    location_anchor = "    location / {"
    if location_anchor not in content:
        redirect = re.search(r"^    return 302 ([^;]+);$", content, flags=re.MULTILINE)
        if not redirect:
            raise RuntimeError("Expected default redirect was not found")
        replacement = (
            "    location / {\n"
            f"        return 302 {redirect.group(1)};\n"
            "    }"
        )
        content = content[:redirect.start()] + replacement + content[redirect.end():]

    block = f"{FASTDL_BEGIN}\n{FASTDL_LOCATION}{FASTDL_END}\n\n"
    content = content.replace(location_anchor, block + location_anchor, 1)
    path.write_text(content, encoding="utf-8")


def main():
    if len(sys.argv) != 3:
        raise SystemExit("usage: apply_nginx.py API_NGINX_SITE FASTDL_NGINX_SITE")

    apply_api_site(Path(sys.argv[1]))
    apply_fastdl_site(Path(sys.argv[2]))


if __name__ == "__main__":
    main()

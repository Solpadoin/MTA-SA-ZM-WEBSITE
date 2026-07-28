#!/usr/bin/env python3
import re
import sys
from pathlib import Path

BEGIN = "    # BEGIN ZMRPG TELEMETRY"
END = "    # END ZMRPG TELEMETRY"
BLOCK = """    # BEGIN ZMRPG TELEMETRY
    location = /mta/api/events {
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


def main():
    if len(sys.argv) != 2:
        raise SystemExit("usage: apply_nginx.py NGINX_SITE")

    path = Path(sys.argv[1])
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


if __name__ == "__main__":
    main()

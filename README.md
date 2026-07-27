# MTA:SA Zombie Mod RPG

GitHub Pages frontend and VPS integration for **Zombie Mod RPG (2011)**.

## Live Services

- Website: `https://solpadoin.github.io/MTA-SA-ZM-WEBSITE/`
- MTA server: `141.105.130.229:22003`
- Status API: `https://141.105.130.229.sslip.io/mta/api/status`
- World telemetry: `https://141.105.130.229.sslip.io/mta/api/telemetry`

The frontend is a static GitHub Pages site. The VPS only runs the MTA server and a small Python API.

## Live Map

The `zmrpg_telemetry` MTA resource sends a world snapshot to the local API every five seconds. The public response contains:

- Online players and last known positions for offline players
- Zombies
- Vehicles
- Server-created markers
- Zombie-proof safe zones

Player account names, IP addresses and serials are never returned by the public API. Stable public player IDs are SHA-256 hashes.

The map uses GTA world bounds from `-3000` to `3000` on both axes. MTA `(x, y)` coordinates map to Leaflet `[y, x]`.

## Gameplay Deployment

Pushes to `main` automatically deploy gameplay, telemetry and backend changes through `.github/workflows/deploy-vps.yml`.

Required GitHub Actions secrets:

| Secret | Value |
| --- | --- |
| `VDS_HOST` | VPS hostname or IP |
| `VDS_USER` | SSH deployment user |
| `VDS_SSH_KEY` | Private SSH key authorized on the VPS |

Each deployment:

1. Backs up the current MTA resources, MTA configuration, ACL, backend and nginx site.
2. Overlays the maintained resource files.
3. Enforces the 100-player configuration and a single copy of each gameplay system.
4. Restarts and verifies MTA, nginx and the telemetry API.
5. Restores the backup automatically if verification fails.

Backups are stored under `/opt/mta-zombie-rpg/backups/`.

## Network Ports

- `22003/udp`: MTA game traffic
- `22005/tcp`: MTA HTTP resource downloads
- `22126/udp`: ASE server query (`game port + 123`)

The telemetry ingestion endpoint is bound to `127.0.0.1:18080` and is not publicly writable.

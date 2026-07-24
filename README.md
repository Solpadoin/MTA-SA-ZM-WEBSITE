# MTA:SA Zombie Mod RPG Website

GitHub Pages frontend for the **Zombie Mod RPG (2011)** Multi Theft Auto: San Andreas server.

## Server

- Address: `141.105.130.229:22003`
- Slots: `100`
- Game: Multi Theft Auto: San Andreas
- Mode: Zombie Survival RPG

## What It Shows

- Server availability
- Online and max player count
- Current map and mode from the MTA ASE query port
- Recent server log events
- Quick `mtasa://` join link

## MTA Status API

The frontend runs from GitHub Pages and polls the mini backend on the VPS:

```text
https://141.105.130.229.sslip.io/mta/api/status
```

For VPS deployment, run `backend/mta_status_api.py` on the same machine as the MTA server and proxy `/mta/api/status` to it with nginx.

The API reads live MTA data from the ASE UDP port, which is `serverport + 123`. With the default MTA port this is:

```text
22003 UDP - game port
22005 TCP - internal HTTP resource download port
22126 UDP - ASE query port
```

This is different from the CS 1.6 website flow, which uses AMXX-exported JSON files.

# whip_revive

Revive system for **WhipFX**, built as a standalone FiveM resource.

When a player is revived or healed, they get a clean on-screen notification:

> ✅ **You have been fully healed!**

*(Add your screenshot here, e.g. `![Heal notification](images/healed.png)`)*

---

## Features

- Revive system designed to work with WhipFX
- Clean heal notification shown on revive
- Client / server / shared structure for easy editing
- Configurable through a single `config.lua`

## Requirements

- A FiveM server (latest recommended artifacts)
- WhipFX

## Installation

1. Download or clone this repository:
   ```bash
   git clone https://github.com/BaconSpaces/whip_revive.git
   ```
2. Place the `whip_revive` folder in your server's `resources` directory.
3. Add this to your `server.cfg` (after WhipFX):
   ```cfg
   ensure whip_revive
   ```
4. Adjust `config.lua` to your liking, then restart the server.

## Configuration

All settings live in `config.lua`. Open it to change options such as notification text and revive behavior.

## Project Structure

```
whip_revive/
├── client/        # Client-side scripts
├── server/        # Server-side scripts
├── shared/        # Shared code
├── config.lua     # Resource configuration
├── fxmanifest.lua # Resource manifest
└── README.md
```

## Usage

Once installed and started, the revive system works automatically. Revived players receive the **"You have been fully healed!"** notification.



## Credits

Made by [BaconSpaces](https://github.com/BaconSpaces).

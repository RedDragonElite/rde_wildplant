# 🌱 RDE Wild Plants — Advanced Plant Growing System

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-red?style=for-the-badge&logo=github)
![License](https://img.shields.io/badge/license-RDE%20Black%20Flag%20v6.66-black?style=for-the-badge)
![FiveM](https://img.shields.io/badge/FiveM-Compatible-orange?style=for-the-badge)
![ox_core](https://img.shields.io/badge/ox__core-Required-blue?style=for-the-badge)
![Free](https://img.shields.io/badge/price-FREE%20FOREVER-brightgreen?style=for-the-badge)

**4-stage growth system, dynamic weather effects, quality-based harvest yield, real-time triple sync, and full ox_core integration.**
Built on ox_core · ox_lib · ox_inventory · ox_target · oxmysql

*Built by [Red Dragon Elite](https://rd-elite.com) | SerpentsByte*

</div>

---
![RDE_WildPlants_Logo](https://github.com/user-attachments/assets/6d41e1f2-8ec2-4b8f-ab91-b54b4c4d3d6a)

## 📖 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [How It Works](#-how-it-works)
- [Dependencies](#-dependencies)
- [Installation](#-installation)
- [Item Setup](#-item-setup)
- [Configuration](#%EF%B8%8F-configuration)
- [Admin Commands](#-admin-commands)
- [Database](#-database)
- [Performance](#-performance)
- [Troubleshooting](#-troubleshooting)
- [Changelog](#-changelog)
- [License](#-license)

---

## 🎯 Overview

**RDE Wild Plants** is a production-ready plant growing system for FiveM servers running ox_core. Plants grow through four realistic stages, react dynamically to weather, produce quality-based harvest yields, and sync perfectly across all clients via a triple sync architecture — all persistent across server restarts.

### Why RDE Wild Plants?

| Feature | Generic Growing Scripts | RDE Wild Plants |
|---|---|---|
| Multi-stage growth | Sometimes 2 | ✅ 4 stages |
| Weather effects | ❌ | ✅ Rain, thunder, sun, fog |
| Quality system | ❌ | ✅ Affects harvest yield |
| Real-time sync | Polling | ✅ Triple sync architecture |
| 3D text display | ❌ | ✅ Stage + time remaining |
| Random events | ❌ | ✅ 5% failure chance |
| Database persistent | Sometimes | ✅ Always — auto table |
| Triple admin verification | ❌ | ✅ ACE + ox_core + Steam |

---

## ✨ Features

### 🌿 Growth System
- 4-stage progression: Seedling → Young Plant → Flowering → Ready to Harvest
- ~45 minutes total growth time (fully configurable per stage)
- 3D text above each plant showing current stage and time remaining
- 5% random failure chance for added realism
- Plants persist across server restarts via MySQL

### 🌦️ Dynamic Weather Effects
- Rain → 20% faster growth
- Extra Sunny → 15% faster growth
- Thunderstorm → 20% slower growth
- Foggy → 15% slower growth
- Weather is checked live and affects all active plants in real time

### 📊 Quality System
- Each planted seed generates a random quality value (80–100%)
- Quality directly scales the harvest yield
- Weather bonus at harvest time applies an additional multiplier
- 30% chance for a bonus seed on successful harvest

### 🔄 Synchronization
- Triple sync system — statebags + server events + client callbacks
- New players receive full plant state on join
- All updates broadcast instantly to all connected clients

### 🛡️ Admin System
- Triple verification: ACE permissions + ox_core groups + Steam ID whitelist
- Admin-only commands for plant management and debugging

---

## 🌿 How It Works

1. **Planting** — Player uses a `weed_seed` item near valid ground. ox_target interaction starts the process.
2. **Growth** — Plant advances through 4 stages over ~45 minutes. Weather speeds up or slows down progression.
3. **Harvesting** — When stage 4 is reached, player uses `harvest_tool` via ox_target to harvest.
4. **Rewards** — Player receives 25–75 `harvested_weed` items, scaled by quality and weather bonus. 30% chance for a bonus seed.

---

## 📦 Dependencies

| Resource | Required | Notes |
|---|---|---|
| [oxmysql](https://github.com/communityox/oxmysql) | ✅ Required | Database layer |
| [ox_core](https://github.com/communityox/ox_core) | ✅ Required | Player/character framework |
| [ox_lib](https://github.com/communityox/ox_lib) | ✅ Required | UI, callbacks, notifications |
| [ox_inventory](https://github.com/communityox/ox_inventory) | ✅ Required | Seed and harvest items |
| [ox_target](https://github.com/communityox/ox_target) | ✅ Required | Plant interaction |

---

## 🚀 Installation

### 1. Clone the repository

```bash
cd resources
git clone https://github.com/RedDragonElite/rde_wildplant.git
```

### 2. Add to `server.cfg`

```cfg
ensure oxmysql
ensure ox_core
ensure ox_lib
ensure ox_inventory
ensure ox_target
ensure rde_wildplants
```

> **Order matters.** `rde_wildplants` must start **after** all its dependencies.

### 3. Database

The `rde_plants` table is created automatically on first start. No manual SQL import needed.

### 4. Add items (see below)

### 5. Configure admin permissions in `config.lua`

### 6. Restart

```
restart rde_wildplants
```

---

## 📦 Item Setup

Add the following to `ox_inventory/data/items.lua`:

```lua
['weed_seed'] = {
    label       = 'Weed Seed',
    weight      = 10,
    stack       = true,
    close       = true,
    description = 'A seed for growing plants',
},

['harvest_tool'] = {
    label       = 'Harvest Tool',
    weight      = 500,
    stack       = false,
    close       = true,
    description = 'Tool for harvesting plants',
},

['harvested_weed'] = {
    label       = 'Harvested Weed',
    weight      = 50,
    stack       = true,
    close       = true,
    description = 'Freshly harvested plant material',
},
```

---

## ⚙️ Configuration

All values are configurable in `config.lua`. Key settings:

### Growth Stages (minutes)

```lua
Config.GrowthStages = {
    [1] = 15 * 60,   -- Seedling     → 15 min
    [2] = 15 * 60,   -- Young Plant  → 15 min
    [3] = 15 * 60,   -- Flowering    → 15 min
    [4] = 0,         -- Ready — harvest immediately
}
```

### Weather Multipliers

```lua
Config.WeatherMultipliers = {
    RAIN       = 1.20,   -- 20% faster
    EXTRASUNNY = 1.15,   -- 15% faster
    THUNDER    = 0.80,   -- 20% slower
    FOGGY      = 0.85,   -- 15% slower
}
```

### Harvest Rewards

```lua
Config.Harvest = {
    baseMin       = 25,     -- minimum items
    baseMax       = 75,     -- maximum items
    bonusSeedChance = 0.30, -- 30% chance for bonus seed
    failureChance   = 0.05, -- 5% plant failure chance
}
```

### Admin System

```lua
Config.AdminSystem = {
    checkOrder    = {'ace', 'oxcore', 'steam'},
    acePermission = 'rde.plants.admin',
    oxGroups      = { admin = 0, superadmin = 0 },
    steamIds      = { 'steam:110000xxxxxxxx' },
}
```

### ACE Permissions (server.cfg)

```cfg
add_ace group.admin rde.plants.admin allow
add_principal identifier.steam:110000xxxxxxxx group.admin
```

---

## 📋 Admin Commands

| Command | Description |
|---|---|
| `/deleteplants` | Delete all active plants from world and database |
| `/countplants` | Show total active plant count |
| `/debugplants` | Client-side debug info for nearby plants |
| `/debugplantsserver` | Server-side plant state dump to console |

---

## 🗄️ Database

Table is auto-created on first start:

```sql
CREATE TABLE rde_plants (
    id         VARCHAR(64)  PRIMARY KEY,
    model      VARCHAR(64)  NOT NULL,
    coords     JSON         NOT NULL,
    stage      INT          DEFAULT 1,
    quality    FLOAT        DEFAULT 1.0,
    planted_by VARCHAR(64)  NOT NULL,
    planted_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_planted_by (planted_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## ⚡ Performance

- ~800 lines total — lightweight by design
- Efficient rendering via LOD-aware 3D text (only drawn within range)
- Database operations are async — no blocking calls
- Weather checks are cached, not polled every tick
- Plant sync fires only on state change, not on a loop

---

## 🐛 Troubleshooting

**Plants not showing after restart?**
Check that `oxmysql` is fully started before `rde_wildplants`. Fix `ensure` order in `server.cfg` if needed. Run `/countplants` to confirm DB entries exist.

**Harvest tool not triggering ox_target option?**
Make sure `ox_target` is started before `rde_wildplants`. Check F8 console for export errors on resource start.

**Weather effects not applying?**
Enable `Config.Debug = true` and check server console. Confirm the weather type string returned by your server matches the keys in `Config.WeatherMultipliers`.

**Plants stuck at stage 1?**
Check server console for timer errors. Verify `oxmysql` is connected and the `rde_plants` table exists (`SHOW TABLES LIKE 'rde_plants'`).

**Admin commands not working?**
Verify your ACE setup in `server.cfg` and that your Steam ID in `Config.AdminSystem.steamIds` matches the exact hex format (`steam:110000xxxxxxxxx`).

---

## 📝 Changelog

### v1.0.0 — Initial Release
- 4-stage plant growth system
- Dynamic weather integration (rain, thunder, sun, fog)
- Quality-based harvest yield
- Triple sync system for perfect multiplayer support
- Triple admin verification (ACE + ox_core + Steam)
- 3D text display per plant
- Random failure events
- Multi-language support (EN/DE)
- Auto database table creation

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit: `git commit -m 'Add your feature'`
4. Push: `git push origin feature/your-feature`
5. Open a Pull Request

Guidelines: follow existing Lua conventions, comment complex logic, test on a live server before PR, update docs if adding features.

---

## 📜 License

```
###################################################################################
#                                                                                 #
#      .:: RED DRAGON ELITE (RDE)  -  BLACK FLAG SOURCE LICENSE v6.66 ::.         #
#                                                                                 #
#   PROJECT:    RDE_WILDPLANTS v1.0.0 (ADVANCED PLANT GROWING SYSTEM FOR FIVEM)   #
#   ARCHITECT:  .:: RDE ⧌ Shin [△ ᛋᛅᚱᛒᛅᚾᛏᛋ ᛒᛁᛏᛅ ▽] ::. | https://rd-elite.com     #
#   ORIGIN:     https://github.com/RedDragonElite                                 #
#                                                                                 #
#   WARNING: THIS CODE IS PROTECTED BY DIGITAL VOODOO AND PURE HATRED FOR LEAKERS #
#                                                                                 #
#   [ THE RULES OF THE GAME ]                                                     #
#                                                                                 #
#   1. // THE "FUCK GREED" PROTOCOL (FREE USE)                                    #
#      You are free to use, edit, and abuse this code on your server.             #
#      Learn from it. Break it. Fix it. That is the hacker way.                   #
#      Cost: 0.00€. If you paid for this, you got scammed by a rat.               #
#                                                                                 #
#   2. // THE TEBEX KILL SWITCH (COMMERCIAL SUICIDE)                              #
#      Listen closely, you parasites:                                             #
#      If I find this script on Tebex, Patreon, or in a paid "Premium Pack":      #
#      > I will DMCA your store into oblivion.                                    #
#      > I will publicly shame your community.                                    #
#      > I hope your server lag spikes to 9999ms every time you blink.            #
#      SELLING FREE WORK IS THEFT. AND I AM THE JUDGE.                            #
#                                                                                 #
#   3. // THE CREDIT OATH                                                         #
#      Keep this header. If you remove my name, you admit you have no skill.      #
#      You can add "Edited by [YourName]", but never erase the original creator.  #
#      Don't be a skid. Respect the architecture.                                 #
#                                                                                 #
#   4. // THE CURSE OF THE COPY-PASTE                                             #
#      This code uses async timers, weather hooks, and a triple sync layer.       #
#      If you just copy-paste without reading, it WILL break.                     #
#      Don't come crying to my DMs. RTFM or learn to code.                        #
#                                                                                 #
#   --------------------------------------------------------------------------    #
#   "We build the future on the graves of paid resources."                        #
#   "REJECT MODERN MEDIOCRITY. EMBRACE RDE SUPERIORITY."                          #
#   --------------------------------------------------------------------------    #
###################################################################################
```

**TL;DR:**
- ✅ Free forever — use it, edit it, learn from it
- ✅ Keep the header — credit where it's due
- ❌ Don't sell it — commercial use = instant DMCA
- ❌ Don't be a skid — copy-paste without reading won't work anyway

---

## 🌐 Community & Support

| | |
|---|---|
| 🐙 GitHub | [RedDragonElite](https://github.com/RedDragonElite) |
| 🌍 Website | [rd-elite.com](https://rd-elite.com) |
| 🔵 Nostr (RDE) | [RedDragonElite](https://primal.net/p/nprofile1qqsv8km2w8yr0sp7mtk3t44qfw7wmvh8caqpnrd7z6ll6mn9ts03teg9ha4rl) |
| 🔵 Nostr (Shin) | [SerpentsByte](https://primal.net/p/nprofile1qqs8p6u423fappfqrrmxful5kt95hs7d04yr25x88apv7k4vszf4gcqynchct) |
| 🚪 RDE Doors | [rde_doors](https://github.com/RedDragonElite/rde_doors) |
| 🚗 RDE Car Service | [rde_carservice](https://github.com/RedDragonElite/rde_carservice) |
| 🎯 RDE Skills | [rde_skills](https://github.com/RedDragonElite/rde_skills) |
| 🎮 RDE Props | [rde_props](https://github.com/RedDragonElite/rde_props) |
| 📡 RDE Nostr Log | [rde_nostr_log](https://github.com/RedDragonElite/rde_nostr_log) |

**When asking for help, always include:**
- Full error from server console or txAdmin
- Your `server.cfg` resource start order
- ox_core / ox_lib versions in use

---

<div align="center">

*"We build the future on the graves of paid resources."*

**REJECT MODERN MEDIOCRITY. EMBRACE RDE SUPERIORITY.**

🐉 Made with 🔥 by [Red Dragon Elite](https://rd-elite.com)

[⬆ Back to Top](#-rde-wild-plants--advanced-plant-growing-system)

</div>

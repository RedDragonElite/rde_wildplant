# 🌱 [FREE] RDE Wild Plants - Advanced Plant Growing System for ox_core
A highly optimized and feature-rich plant growing system with real-time synchronization, weather effects, and quality system.

## 📸 Preview
https://youtu.be/2vJVCgRXoyI?si=ylMRNdCcHzEkG3iA

## 📸 Screenshots
wildplants1|690x388 wildplants2|690x388

## ✨ Features
- 🌿 **4-Stage Growth System** - Seedling → Young Plant → Flowering → Ready to Harvest
- 🌦️ **Dynamic Weather Effects** - Rain speeds up growth, thunderstorms slow it down
- 📊 **Quality System** - Each plant has unique quality affecting harvest yield
- 🎯 **ox_target Integration** - Smooth interaction system
- 🗄️ **Database Persistence** - Plants survive server restarts
- 🔄 **Triple Sync System** - Perfect synchronization across all clients
- 🛡️ **Triple Admin Verification** - ACE permissions, ox_core groups, Steam ID whitelist
- 🌍 **Multi-language Support** - English and German included (easily expandable)
- 🎨 **3D Text Display** - Shows growth stage and time remaining
- ⚡ **Performance Optimized** - Efficient rendering and database operations
- 🎲 **Random Events** - 5% plant failure chance adds realism

## 🎮 How It Works
1. **Planting**: Use a seed item, plant grows through 4 stages (~45 minutes total)
2. **Weather Impact**: Rain = 20% faster growth, Thunder = 20% slower
3. **Harvesting**: Use harvest tool when plant reaches stage 4
4. **Rewards**: Get 25-75 items based on quality + 30% chance for bonus seed

## 📋 Requirements
- ox_core
- ox_lib
- ox_inventory
- ox_target
- oxmysql

## 📦 Installation
1. Download and extract to your resources folder
2. Add `ensure rde_wildplants` to your server.cfg (after ox dependencies)
3. Add the following items to your `ox_inventory/data/items.lua`:

```lua
['weed_seed'] = {
    label = 'Weed Seed',
    weight = 10,
    stack = true,
    close = true,
    description = 'A seed for growing plants'
},

['harvest_tool'] = {
    label = 'Harvest Tool',
    weight = 500,
    stack = false,
    close = true,
    description = 'Tool for harvesting plants'
},

['harvested_weed'] = {
    label = 'Harvested Weed',
    weight = 50,
    stack = true,
    close = true,
    description = 'Freshly harvested plant material'
}
```

4. Configure admin permissions in `config.lua`
5. Restart your server
6. Database table is created automatically!

## 🎯 Configuration Highlights

**Growth Times:**
- Stage 1 (Seedling): 15 minutes
- Stage 2 (Young Plant): 15 minutes
- Stage 3 (Flowering): 15 minutes
- Stage 4 (Ready): Instant harvest

**Weather Multipliers:**
- Rain: 1.2x faster
- Extra Sunny: 1.15x faster
- Thunder: 0.8x slower
- Foggy: 0.85x slower

**Harvest Rewards:**
- Base: 25-75 items
- Modified by plant quality (80-100%)
- Modified by weather bonus
- 30% chance for bonus seed

*All configurable in config.lua!*

## 🎬 Video Preview
https://youtu.be/2vJVCgRXoyI?si=ylMRNdCcHzEkG3iA

## 🔧 Admin Commands
- `/deleteplants` - Delete all plants (admin only)
- `/countplants` - Show active plant count
- `/debugplants` - Client debug info
- `/debugplantsserver` - Server debug info

## 💬 Support
For support, bug reports, or feature requests, please open an issue on GitHub or contact me via:
- Forum DM

## 📜 Changelog
**v1.0.0 - Initial Release**
- Complete growing system with 4 stages
- Weather integration
- Quality system
- Triple sync for perfect multiplayer support
- Multi-language support (EN/DE)

## 🙏 Credits
- **Framework**: ox_core by Overextended
- **Libraries**: ox_lib, ox_inventory, ox_target
- **Development**: RDE Development

## 📥 Download
**GitHub**: https://github.com/RedDragonElite/rde_wildplant

**Installation difficulty**: ⭐⭐☆☆☆ (Easy - plug and play)

## Resource Information (Required)

| Category | Details |
|----------|---------|
| Code is accessible | Yes (Open Source) |
| Subscription-based | No (Free Forever) |
| Lines (approximately) | ~800 lines |
| Requirements | ox_core, ox_lib, ox_inventory, ox_target, oxmysql |
| Support | Yes (GitHub Issues + Forum) |

## 🎯 Why Choose This Script?
✅ **Completely Free** - No hidden costs, no subscriptions  
✅ **Production Ready** - Tested and optimized  
✅ **Well Documented** - Full README included  
✅ **Active Support** - I respond to issues and suggestions  
✅ **Open Source** - Learn from it, modify it, make it yours

*If you like this resource, please consider leaving a ⭐ on GitHub and a positive review here!*

---

**License**: Open Source  
**Version**: 1.0.0  
**Last Update**: November 2025  
**Tested on**: FiveM b3570+ with ox_core

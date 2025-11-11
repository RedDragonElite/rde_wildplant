Config = {}

-- 🌐 LOCALIZATION SETTINGS
Config.DefaultLanguage = 'en' -- Options: 'en', 'de'
Config.Languages = {
    en = {
        -- 🎯 General
        success = '✅ Success',
        error = '❌ Error',
        warning = '⚠️ Warning',
        info = 'ℹ️ Information',
        cancelled = '🚫 Cancelled',
        processing = '⏳ Processing...',
        -- 🌱 Plant Stages
        seedling = '🌱 Seedling',
        young_plant = '🌿 Young Plant',
        flowering = '🌾 Flowering',
        ready_to_harvest = '✅ Ready to Harvest',
        -- 🌿 Notifications
        cant_plant = {
            title = '❌ Cannot Plant',
            description = 'You cannot plant here.',
            icon = 'ban'
        },
        planted = {
            title = '✅ Planted',
            description = 'Your plant is now growing!',
            icon = 'seedling'
        },
        harvested = {
            title = '✅ Harvested',
            description = 'You harvested %sx %s!',
            icon = 'cannabis'
        },
        destroyed = {
            title = '🗑️ Plant Destroyed',
            description = 'The plant has been removed.',
            icon = 'trash'
        },
        too_steep = {
            title = '❌ Too Steep',
            description = 'The ground is too steep to plant.',
            icon = 'mountain'
        },
        no_space = {
            title = '❌ No Space',
            description = 'Not enough space above the plant.',
            icon = 'compress'
        },
        too_close = {
            title = '❌ Too Close',
            description = 'Too close to another plant.',
            icon = 'compress-arrows-alt'
        },
        indoors = {
            title = '❌ Indoors',
            description = 'You cannot plant indoors.',
            icon = 'home'
        },
        in_water = {
            title = '❌ In Water',
            description = 'You cannot plant in water.',
            icon = 'water'
        },
        invalid_ground = {
            title = '❌ Invalid Ground',
            description = 'This ground is not suitable for planting.',
            icon = 'exclamation-triangle'
        },
        no_seed = {
            title = '❌ No Seed',
            description = 'You need a seed to plant.',
            icon = 'seedling'
        },
        no_tool = {
            title = '❌ No Tool',
            description = 'You need a harvesting tool.',
            icon = 'tools'
        },
        not_ready = {
            title = '⏳ Not Ready',
            description = 'This plant is not ready for harvest.',
            icon = 'clock'
        },
        inventory_full = {
            title = '❌ Inventory Full',
            description = 'Your inventory is full!',
            icon = 'box'
        },
        weather_boost = '🌤️ Growth Boost: +%d%%',
        minutes_remaining = '⏱️ %d minutes',
    },
    de = {
        -- 🎯 Allgemein
        success = '✅ Erfolg',
        error = '❌ Fehler',
        warning = '⚠️ Warnung',
        info = 'ℹ️ Information',
        cancelled = '🚫 Abgebrochen',
        processing = '⏳ Wird bearbeitet...',
        -- 🌱 Pflanzenstadien
        seedling = '🌱 Keimling',
        young_plant = '🌿 Junge Pflanze',
        flowering = '🌾 Blütephase',
        ready_to_harvest = '✅ Erntereif',
        -- 🌿 Benachrichtigungen
        cant_plant = {
            title = '❌ Kann nicht gepflanzt werden',
            description = 'Hier kannst du nicht pflanzen.',
            icon = 'ban'
        },
        planted = {
            title = '✅ Gepflanzt',
            description = 'Deine Pflanze wächst jetzt!',
            icon = 'seedling'
        },
        harvested = {
            title = '✅ Geerntet',
            description = 'Du hast %sx %s geerntet!',
            icon = 'cannabis'
        },
        destroyed = {
            title = '🗑️ Pflanze zerstört',
            description = 'Die Pflanze wurde entfernt.',
            icon = 'trash'
        },
        too_steep = {
            title = '❌ Zu steil',
            description = 'Der Boden ist zu steil zum Pflanzen.',
            icon = 'mountain'
        },
        no_space = {
            title = '❌ Kein Platz',
            description = 'Nicht genug Platz über der Pflanze.',
            icon = 'compress'
        },
        too_close = {
            title = '❌ Zu nah',
            description = 'Zu nah an einer anderen Pflanze.',
            icon = 'compress-arrows-alt'
        },
        indoors = {
            title = '❌ Drinnen',
            description = 'Du kannst nicht drinnen pflanzen.',
            icon = 'home'
        },
        in_water = {
            title = '❌ Im Wasser',
            description = 'Du kannst nicht im Wasser pflanzen.',
            icon = 'water'
        },
        invalid_ground = {
            title = '❌ Ungültiger Boden',
            description = 'Dieser Boden ist nicht geeignet.',
            icon = 'exclamation-triangle'
        },
        no_seed = {
            title = '❌ Kein Samen',
            description = 'Du brauchst einen Samen zum Pflanzen.',
            icon = 'seedling'
        },
        no_tool = {
            title = '❌ Kein Werkzeug',
            description = 'Du brauchst ein Erntewerkzeug.',
            icon = 'tools'
        },
        not_ready = {
            title = '⏳ Noch nicht bereit',
            description = 'Diese Pflanze ist noch nicht erntereif.',
            icon = 'clock'
        },
        inventory_full = {
            title = '❌ Inventar voll',
            description = 'Dein Inventar ist voll!',
            icon = 'box'
        },
        weather_boost = '🌤️ Wachstumsboost: +%d%%',
        minutes_remaining = '⏱️ %d Minuten',
    }
}

-- 🎨 Helper function for Language Strings
function GetLanguageString(key, ...)
    local lang = Config.Languages[Config.DefaultLanguage]
    local str = lang[key]
    if type(str) == 'table' then
        return str
    elseif select('#', ...) > 0 then
        return string.format(str, ...)
    else
        return str
    end
end

-- 🌱 Plant growth stages
Config.GrowthStages = {
    [1] = {
        model = `prop_weed_02`,
        time = 900, -- 15 minutes (in seconds)
        label = "seedling",
        scale = 0.1,
        icon = "seedling"
    },
    [2] = {
        model = `prop_weed_02`,
        time = 900, -- 15 minutes
        label = "young_plant",
        scale = 0.3,
        icon = "leaf"
    },
    [3] = {
        model = `prop_weed_02`,
        time = 900, -- 15 minutes
        label = "flowering",
        scale = 0.6,
        icon = "cannabis"
    },
    [4] = {
        model = `prop_weed_01`,
        time = 0, -- Ready to harvest
        label = "ready_to_harvest",
        scale = 1.0,
        icon = "check-circle"
    }
}

-- 🌿 Harvest settings
Config.HarvestRewards = {
    min = 25,
    max = 75,
    item = "harvested_weed"
}

-- 📦 Item settings
Config.SeedItem = "weed_seed"
Config.HarvestTool = "harvest_tool"

-- 🎮 Animation settings
Config.PlantingAnimation = {
    dict = "amb@world_human_gardener_plant@male@base",
    anim = "base",
    duration = 4000,
    flag = 1
}

Config.HarvestingAnimation = {
    dict = "amb@world_human_gardener_plant@male@base",
    anim = "base",
    duration = 4000,
    flag = 1
}

-- 📏 Distance settings
Config.Distances = {
    drawText = 5.0,
    interact = 2.5,
    minBetweenPlants = 1.5
}

-- 🎨 Text display settings
Config.TextDisplay = {
    updateInterval = 1000,
    scale = 0.4,
    font = 4,
    colors = {
        default = {r = 255, g = 255, b = 255, a = 215},
        ready = {r = 0, g = 255, b = 0, a = 215},
        growing = {r = 255, g = 200, b = 0, a = 215}
    }
}

-- 🌱 Planting restrictions
Config.PlantingRestrictions = {
    MinDistanceBetweenPlants = 1.5,
    MaxGroundAngle = 30.0,
    MinHeightClearance = 4.0,
    CheckRadius = 2.0
}

-- 🗄️ Database settings
Config.Database = {
    table = "rde_wildplants",
    saveInterval = 300000 -- 5 minutes (in milliseconds)
}

-- 🚫 Invalid ground materials
Config.InvalidGroundMaterials = {
    [509131518] = true,    -- ROAD CONCRETE
    [-1137527917] = true,  -- ROAD ASPHALT
    [-1907520769] = true,  -- ROAD TARMAC
    [282940568] = true,    -- PAVEMENT
    [-840216541] = true,   -- STONE
    [-1885547121] = true,  -- CONCRETE
    [1619704960] = true,   -- MARBLE
    [1945073303] = true,   -- CERAMIC
    [-1634184340] = true,  -- TILE
    [1241759715] = true,   -- SIDEWALK
}

-- ⚡ Performance optimization
Config.Performance = {
    updateInterval = 1000,
    objectStreamingDistance = 100.0,
    maxVisiblePlants = 50,
    cullDistance = 150.0
}

-- 🐞 Debug settings
Config.Debug = true -- Set to false for production!

-- 🌦️ Growth settings
Config.Growth = {
    enableWeather = true,
    randomFailureChance = 0.05, -- 5% chance that plant dies
    weatherEffects = {
        RAIN = 1.2,        -- 20% faster in rain
        THUNDER = 0.8,     -- 20% slower in thunderstorm
        CLEARING = 1.1,    -- 10% faster
        EXTRASUNNY = 1.15, -- 15% faster in sun
        CLEAR = 1.1,       -- 10% faster
        CLOUDS = 1.0,      -- Normal
        OVERCAST = 0.9,    -- 10% slower
        FOGGY = 0.85       -- 15% slower
    }
}

-- 🎯 Target system settings
Config.Target = {
    harvestIcon = "cannabis",
    destroyIcon = "trash",
    harvestDistance = 2.5
}

-- 🛡️ Admin System (Triple Verification)
Config.AdminSystem = {
    acePermission = 'rde.weed.admin',
    steamIds = {
        -- 'steam:110000xxxxxxxxx' -- Add your Steam IDs here
    },
    oxGroups = {
        ['admin'] = 0,      -- Admin with Grade 0 or higher
        ['superadmin'] = 0, -- Superadmin with Grade 0 or higher
    },
    checkOrder = {'ace', 'oxcore', 'steam'} -- Check order
}

-- 🌱 Show 3D Text
Config.ShowPlantInfo = true -- Set to false to disable 3D text

-- 🔄 Statebag Key
Config.StatebagKey = 'rde_plants'
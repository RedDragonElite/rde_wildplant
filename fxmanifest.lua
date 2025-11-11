fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'RDE Development - Fixed for ox_core v3'
description 'Wild Plant Growing System - Fully Compatible with ox_core v3'
version '2.0.0'

-- 🌐 Dependencies
dependencies {
    'ox_lib',
    'ox_core',
    'ox_inventory',
    'ox_target',
    'oxmysql'
}

-- 📦 Shared
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

-- 💻 Client
client_scripts {
    'client.lua'
}

-- 🖥️ Server
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

-- 📋 Exports (für andere Scripts)
exports {
    'GetAllPlants',
    'GetPlantById',
    'GetPlantsByOwner'
}

server_exports {
    'GetAllPlants',
    'GetPlantById', 
    'GetPlantsByOwner',
    'DeletePlant',
    'CreatePlant'
}
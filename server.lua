-- 🌐 Imports & Globals
local plants = {}
local loadedPlayers = {}
local currentWeather = "CLEAR"
local debugEnabled = Config.Debug
local MySQL = MySQL

-- 🌱 Database Init (WITH AUTO-LOAD)
CreateThread(function()
    while GetResourceState('oxmysql') ~= 'started' do
        Wait(100)
    end

    Wait(1000)
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS ]]..Config.Database.table..[[ (
            id VARCHAR(50) PRIMARY KEY,
            coords JSON NOT NULL,
            stage INT NOT NULL DEFAULT 1,
            planted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            time_left INT NOT NULL DEFAULT 0,
            owner VARCHAR(50) NOT NULL,
            data JSON DEFAULT '{}'
        )
    ]])

    Wait(500)
    local results = MySQL.query.await('SELECT * FROM '..Config.Database.table)
    if results then
        for i = 1, #results do
            local row = results[i]
            plants[row.id] = {
                id = row.id,
                coords = json.decode(row.coords),
                stage = row.stage,
                plantedAt = row.planted_at,
                timeLeft = row.time_left,
                owner = row.owner,
                data = json.decode(row.data) or {}
            }
        end
        if debugEnabled then
            print(string.format("^2[RDE | Weed Plants] Loaded %d plants from database^7", #results))
        end
        
        -- Update global statebag after loading
        Wait(500)
        UpdateGlobalStatebag()
    else
        if debugEnabled then
            print("^3[RDE | Weed Plants] No plants in database^7")
        end
    end
end)

-- 🛡️ Admin Check (Triple Verification) - ox_core v3 compatible
function IsPlayerAdmin(source)
    local player = exports.ox_core:GetPlayer(source)
    if not player then return false end

    local adminConfig = Config.AdminSystem
    local identifier = GetPlayerIdentifierByType(source, 'steam')

    for _, method in ipairs(adminConfig.checkOrder) do
        if method == 'ace' then
            if IsPlayerAceAllowed(source, adminConfig.acePermission) then
                if debugEnabled then
                    print(string.format('🔐 [ADMIN] %s verified via ACE: %s', player.name, adminConfig.acePermission))
                end
                return true
            end
        elseif method == 'oxcore' then
            local groups = player.getGroups()
            for groupName, minGrade in pairs(adminConfig.oxGroups) do
                if groups[groupName] and groups[groupName] >= minGrade then
                    if debugEnabled then
                        print(string.format('🔐 [ADMIN] %s verified via ox_core group: %s', player.name, groupName))
                    end
                    return true
                end
            end
        elseif method == 'steam' then
            if identifier then
                for _, allowedId in ipairs(adminConfig.steamIds) do
                    if identifier == allowedId then
                        if debugEnabled then
                            print(string.format('🔐 [ADMIN] %s verified via Steam: %s', player.name, identifier))
                        end
                        return true
                    end
                end
            end
        end
    end

    if debugEnabled then
        print(string.format('⚠️ [SECURITY] Unauthorized admin attempt by %s [%s]', player.name, identifier or 'unknown'))
    end
    return false
end

-- 🌱 Weather Sync
RegisterNetEvent('rde_plants:updateWeather', function(weather)
    if weather and type(weather) == "string" then
        currentWeather = weather
    end
end)

-- 🌱 Character Events (ox_core v3)
AddEventHandler('ox:playerLoaded', function(playerId, userId, charId)
    loadedPlayers[playerId] = { userId = userId, charId = charId }
    if debugEnabled then
        print(string.format("^2[RDE | Weed Plants] Player %d loaded (CharID: %s, UserID: %d)^7", playerId, charId, userId))
    end
    
    -- Force sync on player load
    SetTimeout(2000, function()
        UpdateGlobalStatebag()
        if debugEnabled then
            print(string.format("^2[RDE | Weed Plants] Forced statebag sync for player %d^7", playerId))
        end
    end)
end)

AddEventHandler('ox:playerLogout', function(playerId, userId, charId)
    loadedPlayers[playerId] = nil
    if debugEnabled then
        print(string.format("^3[RDE | Weed Plants] Player %d logged out (CharID: %s)^7", playerId, charId))
    end
end)

AddEventHandler('playerDropped', function()
    local playerId = source
    loadedPlayers[playerId] = nil
end)

-- 🌱 Helper Functions
local function GetCurrentWeatherMultiplier()
    if not Config.Growth.enableWeather then return 1.0 end
    return Config.Growth.weatherEffects[currentWeather] or 1.0
end

local function SavePlant(plantId)
    if not plants[plantId] then return end

    MySQL.update(
        'UPDATE '..Config.Database.table..' SET stage = ?, time_left = ?, data = ? WHERE id = ?',
        {plants[plantId].stage, plants[plantId].timeLeft, json.encode(plants[plantId].data or {}), plantId}
    )

    if debugEnabled then
        print(string.format("^2[RDE | Weed Plants] Saved plant %s (Stage: %d, Time: %d)^7", plantId, plants[plantId].stage, plants[plantId].timeLeft))
    end
end

local function DeletePlant(plantId)
    if not plants[plantId] then return end
    if debugEnabled then
        print(string.format("^3[RDE | Weed Plants] Deleting plant %s...^7", plantId))
    end

    -- Delete from database
    MySQL.query('DELETE FROM '..Config.Database.table..' WHERE id = ?', {plantId})

    -- Remove from memory
    plants[plantId] = nil

    -- Update global statebag (this will notify all clients)
    UpdateGlobalStatebag()

    if debugEnabled then
        print(string.format("^2[RDE | Weed Plants] Deleted plant %s^7", plantId))
    end
end

local function GetPlayerCharId(playerId)
    if loadedPlayers[playerId] and loadedPlayers[playerId].charId then
        return loadedPlayers[playerId].charId
    end

    local player = exports.ox_core:GetPlayer(playerId)
    if not player then
        if debugEnabled then
            print(string.format("^1[RDE | Weed Plants] Player %d not found in ox_core^7", playerId))
        end
        return nil
    end

    if not player.charId then
        if debugEnabled then
            print(string.format("^1[RDE | Weed Plants] Player %d has no character loaded^7", playerId))
        end
        return nil
    end

    loadedPlayers[playerId] = { userId = player.userId, charId = player.charId }
    return player.charId
end

-- 🌱 STATEBAG UPDATE FUNCTION (FIXED: Proper GlobalState update)
function UpdateGlobalStatebag()
    -- Create a clean copy of plants for statebag
    local plantsForStatebag = {}
    for id, plant in pairs(plants) do
        plantsForStatebag[id] = {
            id = plant.id,
            coords = plant.coords,
            stage = plant.stage,
            timeLeft = plant.timeLeft,
            owner = plant.owner,
            data = plant.data or {}
        }
    end
    
    -- Update GlobalState with the entire plants table
    -- This is the correct way according to FiveM docs
    GlobalState[Config.StatebagKey] = plantsForStatebag
    
    if debugEnabled then
        local count = 0
        for _ in pairs(plantsForStatebag) do count = count + 1 end
        print(string.format("^2[RDE | Weed Plants] Updated GlobalState[%s] with %d plants^7", Config.StatebagKey, count))
    end
end

-- 🌱 Event: SYNC REQUEST
RegisterNetEvent('rde_plants:requestSync', function()
    local source = source
    local charId = GetPlayerCharId(source)

    if not charId then
        if debugEnabled then
            print(string.format("^3[RDE | Weed Plants] Sync request from %d ignored - no character^7", source))
        end
        return
    end

    local plantCount = 0
    for _ in pairs(plants) do plantCount = plantCount + 1 end

    if debugEnabled then
        print(string.format("^2[RDE | Weed Plants] Player %d (CharID: %s) requested sync - %d plants^7", source, charId, plantCount))
    end

    -- Force immediate statebag sync
    UpdateGlobalStatebag()
    
    -- Send direct sync as backup
    TriggerClientEvent('rde_plants:syncPlants', source, plants)
end)

-- 🌱 Event: CREATE PLANT
RegisterNetEvent('rde_plants:createPlant', function(coords)
    local source = source
    local charId = GetPlayerCharId(source)

    if not charId then
        lib.notify(source, {
            title = GetLanguageString('error'),
            description = 'No character loaded',
            type = 'error'
        })
        return
    end

    if not coords or not coords.x or not coords.y or not coords.z then
        if debugEnabled then
            print("^1[RDE | Weed Plants] Invalid coordinates received^7")
        end
        return
    end

    if debugEnabled then
        print(string.format("^3[RDE | Weed Plants] Player %d planting at %.2f, %.2f, %.2f^7", source, coords.x, coords.y, coords.z))
    end

    if not exports.ox_inventory:RemoveItem(source, Config.SeedItem, 1) then
        lib.notify(source, Config.Languages[Config.DefaultLanguage].no_seed)
        return
    end

    local plantId = string.format('%x%x', os.time(), math.random(0, 0xFFFFF))

    plants[plantId] = {
        id = plantId,
        coords = coords,
        stage = 1,
        timeLeft = Config.GrowthStages[1].time,
        owner = tostring(charId),
        plantedAt = os.time(),
        data = {
            quality = math.random(80, 100),
            weather_bonus = 0
        }
    }

    MySQL.insert(
        'INSERT INTO '..Config.Database.table..' (id, coords, stage, planted_at, time_left, owner, data) VALUES (?, ?, ?, NOW(), ?, ?, ?)',
        {
            plantId,
            json.encode(coords),
            1,
            Config.GrowthStages[1].time,
            tostring(charId),
            json.encode(plants[plantId].data)
        },
        function(insertId)
            if insertId then
                if debugEnabled then
                    print(string.format("^2[RDE | Weed Plants] Created plant %s for CharID %s^7", plantId, charId))
                end

                lib.notify(source, Config.Languages[Config.DefaultLanguage].planted)
                
                -- Update statebag to sync to all clients
                UpdateGlobalStatebag()
            else
                if debugEnabled then
                    print("^1[RDE | Weed Plants] Database insert failed^7")
                end
            end
        end
    )
end)

-- 🌱 Event: START HARVESTING
RegisterNetEvent('rde_plants:startHarvesting', function(plantId)
    local source = source

    if not plants[plantId] then
        if debugEnabled then
            print(string.format("^1[RDE | Weed Plants] Plant %s not found for harvesting^7", plantId))
        end
        return
    end

    if plants[plantId].stage ~= 4 then
        lib.notify(source, Config.Languages[Config.DefaultLanguage].not_ready)
        return
    end

    TriggerClientEvent('rde_plants:harvestPlant', source, plantId)
end)

-- 🌱 Event: HARVEST COMPLETE
RegisterNetEvent('rde_plants:harvestComplete', function(plantId)
    local source = source
    local charId = GetPlayerCharId(source)

    if not charId then
        lib.notify(source, {
            title = GetLanguageString('error'),
            description = 'No character loaded',
            type = 'error'
        })
        return
    end

    if not plants[plantId] then
        if debugEnabled then
            print(string.format("^1[RDE | Weed Plants] Plant %s not found (already harvested?)^7", plantId))
        end
        return
    end

    local quality = plants[plantId].data.quality or 100
    local weatherBonus = plants[plantId].data.weather_bonus or 0
    local baseAmount = math.random(Config.HarvestRewards.min, Config.HarvestRewards.max)
    local finalAmount = math.floor(baseAmount * (quality/100) * (1 + weatherBonus))

    if debugEnabled then
        print(string.format("^3[RDE | Weed Plants] Harvest: %d %s (Quality: %d%%, Bonus: %.1f%%)^7",
            finalAmount, Config.HarvestRewards.item, quality, weatherBonus * 100))
    end

    if not exports.ox_inventory:CanCarryItem(source, Config.HarvestRewards.item, finalAmount) then
        lib.notify(source, Config.Languages[Config.DefaultLanguage].inventory_full)
        return
    end

    if exports.ox_inventory:AddItem(source, Config.HarvestRewards.item, finalAmount) then
        if math.random() < 0.3 then
            exports.ox_inventory:AddItem(source, Config.SeedItem, 1)
            if debugEnabled then
                print(string.format("^2[RDE | Weed Plants] Bonus seed given to player %d^7", source))
            end
        end

        lib.notify(source, {
            title = GetLanguageString('success'),
            description = string.format(GetLanguageString('harvested').description, finalAmount, Config.HarvestRewards.item),
            type = 'success',
            icon = 'cannabis'
        })

        DeletePlant(plantId)
    else
        if debugEnabled then
            print(string.format("^1[RDE | Weed Plants] Failed to add items to player %d^7", source))
        end
        lib.notify(source, {
            title = GetLanguageString('error'),
            description = 'Failed to add items',
            type = 'error'
        })
    end
end)

-- 🌱 Event: DESTROY PLANT
RegisterNetEvent('rde_plants:destroyPlant', function(plantId)
    local source = source

    if not IsPlayerAdmin(source) then
        lib.notify(source, {
            title = GetLanguageString('error'),
            description = 'No permission',
            type = 'error'
        })
        return
    end

    DeletePlant(plantId)
    lib.notify(source, {
        title = '🗑️ Plant Destroyed',
        description = 'Plant removed successfully',
        type = 'success'
    })
end)

-- 🌱 GROWTH SYSTEM (FIXED: Better update logic)
CreateThread(function()
    while true do
        Wait(60000) -- Check every minute
        
        local plantsUpdated = false
        
        for plantId, plant in pairs(plants) do
            if plant.timeLeft and plant.timeLeft > 0 then
                local weatherMult = GetCurrentWeatherMultiplier()
                plant.data.weather_bonus = (weatherMult - 1.0)
                
                plant.timeLeft = plant.timeLeft - (60 * weatherMult)
                
                if plant.timeLeft <= 0 and plant.stage < 4 then
                    if math.random() < Config.Growth.randomFailureChance then
                        if debugEnabled then
                            print(string.format("^3[RDE | Weed Plants] Plant %s died (random failure)^7", plantId))
                        end
                        DeletePlant(plantId)
                        plantsUpdated = true
                    else
                        plant.stage = plant.stage + 1
                        plant.timeLeft = Config.GrowthStages[plant.stage].time
                        
                        if debugEnabled then
                            print(string.format("^2[RDE | Weed Plants] Plant %s grew to stage %d^7", plantId, plant.stage))
                        end
                        
                        SavePlant(plantId)
                        plantsUpdated = true
                    end
                else
                    SavePlant(plantId)
                end
            end
        end
        
        -- Update statebag only once if any plants changed
        if plantsUpdated then
            UpdateGlobalStatebag()
        end
    end
end)

-- 🌱 AUTO-SAVE System
CreateThread(function()
    while true do
        Wait(Config.Database.saveInterval)
        local count = 0
        for plantId, _ in pairs(plants) do
            SavePlant(plantId)
            count = count + 1
        end
        if debugEnabled and count > 0 then
            print(string.format("^2[RDE | Weed Plants] Auto-saved %d plants^7", count))
        end
    end
end)

-- 🌱 Admin Commands
RegisterCommand('deleteplants', function(source, args)
    if source == 0 or IsPlayerAdmin(source) then
        local count = 0
        for plantId, _ in pairs(plants) do
            DeletePlant(plantId)
            count = count + 1
        end

        local msg = string.format('Deleted %d plants', count)
        if source > 0 then
            lib.notify(source, {
                title = '🗑️ Plants Deleted',
                description = msg,
                type = 'success'
            })
        else
            print(string.format("^2[RDE | Weed Plants] %s^7", msg))
        end
        
        -- Update statebag
        UpdateGlobalStatebag()
    end
end, true)

RegisterCommand('countplants', function(source)
    local count = 0
    for _ in pairs(plants) do count = count + 1 end

    local msg = string.format('Active plants: %d', count)
    if source > 0 then
        lib.notify(source, {
            title = 'ℹ️ Plant Count',
            description = msg,
            type = 'info'
        })
    else
        print(string.format("^2[RDE | Weed Plants] %s^7", msg))
    end
end, false)

-- 🌱 Resource Stop Handler
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        local count = 0
        for plantId, _ in pairs(plants) do
            SavePlant(plantId)
            count = count + 1
        end
        if debugEnabled then
            print(string.format("^2[RDE | Weed Plants] Saved %d plants on resource stop^7", count))
        end
    end
end)

-- 🌱 Resource Start Handler
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(2000)
        local count = 0
        for _ in pairs(plants) do count = count + 1 end
        
        -- Initialize global statebag on start
        UpdateGlobalStatebag()
        
        if debugEnabled then
            print(string.format("^2[RDE | Weed Plants] Server initialized with %d plants^7", count))
        end
    end
end)

-- 🌱 Debug Command
if Config.Debug then
    RegisterCommand('debugplantsserver', function(source)
        local count = 0
        print("^3=== SERVER PLANTS DEBUG ===^7")
        for id, plant in pairs(plants) do
            count = count + 1
            print(string.format("  %s: Stage=%d, Time=%d, Owner=%s",
                id, plant.stage, plant.timeLeft, plant.owner))
        end
        print(string.format("Total: %d plants", count))
        
        local globalPlants = GlobalState[Config.StatebagKey]
        local globalCount = 0
        if globalPlants then
            for _ in pairs(globalPlants) do globalCount = globalCount + 1 end
        end
        print(string.format("GlobalState[%s] contains: %d plants", Config.StatebagKey, globalCount))
    end, true)
end
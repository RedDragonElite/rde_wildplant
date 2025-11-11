-- 🌐 Imports & Globals
local plants = {}
local debugEnabled = Config.Debug
local playerLoaded = false

-- 🌱 Ground-Z Calculation (optimized)
local function GetGroundZAndNormal(x, y, z)
    local startZ = z + 5.0
    local endZ = z - 10.0
    local rayHandle = StartShapeTestRay(x, y, startZ, x, y, endZ, 1, 0, 0)
    local _, hit, hitCoords, surfaceNormal, materialHash = GetShapeTestResultEx(rayHandle)
    if hit == 1 then
        return hitCoords.z, vector3(surfaceNormal.x, surfaceNormal.y, surfaceNormal.z), materialHash
    end
    local foundGround, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
    if foundGround then
        return groundZ, vector3(0.0, 0.0, 1.0), 0
    end
    return z, vector3(0.0, 0.0, 1.0), 0
end

-- 🎨 Entity Scaling (FIXED: Using native method)
local function SetEntityScale(entity, scale)
    if not DoesEntityExist(entity) then return end
    
    -- Use the native SetObjectScale if available
    if SetObjectScale then
        SetObjectScale(entity, scale)
    else
        -- Fallback: Just set coords properly, scaling via model dimensions
        local coords = GetEntityCoords(entity)
        SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, true)
    end
end

-- 🌱 Create Plant Object
local function createPlantObject(data)
    if not data or not data.stage or not data.coords then
        if debugEnabled then
            print("^1[RDE | Weed Plants] createPlantObject ERROR: Invalid data^7")
        end
        return nil
    end

    local stage = Config.GrowthStages[data.stage]
    if not stage then
        if debugEnabled then
            print(string.format("^1[RDE | Weed Plants] Invalid stage: %d^7", data.stage))
        end
        return nil
    end

    -- Load model
    if not lib.requestModel(stage.model, 10000) then
        if debugEnabled then
            print(string.format("^1[RDE | Weed Plants] Model load failed: %s^7", stage.model))
        end
        return nil
    end

    -- Calculate ground Z
    local groundZ = GetGroundZAndNormal(data.coords.x, data.coords.y, data.coords.z)

    -- Create object
    local object = CreateObject(stage.model, data.coords.x, data.coords.y, groundZ, false, false, false)
    if not DoesEntityExist(object) then
        if debugEnabled then
            print("^1[RDE | Weed Plants] CreateObject failed^7")
        end
        SetModelAsNoLongerNeeded(stage.model)
        return nil
    end

    -- Proper positioning
    PlaceObjectOnGroundProperly(object)
    FreezeEntityPosition(object, true)
    SetEntityAsMissionEntity(object, true, true)
    SetEntityCollision(object, true, true)

    -- Scaling
    if stage.scale and stage.scale ~= 1.0 then
        SetEntityScale(object, stage.scale)
    end

    if debugEnabled then
        print(string.format("^2[RDE | Weed Plants] Created: %s | Stage: %d | Entity: %d | Scale: %.2f^7",
            data.id or "unknown", data.stage, object, stage.scale or 1.0))
    end

    SetModelAsNoLongerNeeded(stage.model)
    return object
end

-- 🌱 Update Plant Object
local function updatePlantObject(plantId, data)
    if not plants[plantId] or not plants[plantId].object then
        if debugEnabled then
            print(string.format("^3[RDE | Weed Plants] updatePlantObject: Plant %s not found, creating new^7", plantId))
        end
        plants[plantId] = data
        plants[plantId].object = createPlantObject(data)
        if plants[plantId].object then
            setupPlantTarget(plantId, data)
        end
        return
    end

    local currentModel = GetEntityModel(plants[plantId].object)
    local stage = Config.GrowthStages[data.stage]
    if not stage then return end

    -- Only recreate if model changes
    if currentModel ~= stage.model then
        if debugEnabled then
            print(string.format("^3[RDE | Weed Plants] Stage change for %s: %d -> %d^7", plantId, plants[plantId].stage, data.stage))
        end

        removePlantObject(plantId, true)

        plants[plantId] = data
        plants[plantId].object = createPlantObject(data)
        if plants[plantId].object then
            setupPlantTarget(plantId, data)
        end
    else
        -- Only update data
        plants[plantId].stage = data.stage
        plants[plantId].timeLeft = data.timeLeft
        plants[plantId].data = data.data
    end
end

-- 🌱 ox_target Setup
function setupPlantTarget(plantId, data)
    if not plants[plantId] or not plants[plantId].object or not DoesEntityExist(plants[plantId].object) then
        return
    end

    local targetOptions = {}
    if data.stage == 4 then
        table.insert(targetOptions, {
            name = 'plant_harvest_' .. plantId,
            label = GetLanguageString('ready_to_harvest'),
            icon = Config.Target.harvestIcon,
            distance = Config.Target.harvestDistance,
            onSelect = function()
                TriggerServerEvent('rde_plants:startHarvesting', plantId)
            end
        })
    end

    table.insert(targetOptions, {
        name = 'plant_destroy_' .. plantId,
        label = GetLanguageString('destroyed').title,
        icon = Config.Target.destroyIcon,
        distance = Config.Target.harvestDistance,
        onSelect = function()
            TriggerServerEvent('rde_plants:destroyPlant', plantId)
        end
    })

    exports.ox_target:addLocalEntity(plants[plantId].object, targetOptions)
    
    if debugEnabled then
        print(string.format("^2[RDE | Weed Plants] Target added for %s (Stage: %d, Options: %d)^7", plantId, data.stage, #targetOptions))
    end
end

-- 🌱 Remove Plant Object
function removePlantObject(plantId, skipTableCleanup)
    if not plants[plantId] then return end
    
    if plants[plantId].object and DoesEntityExist(plants[plantId].object) then
        exports.ox_target:removeLocalEntity(plants[plantId].object, {
            'plant_harvest_' .. plantId,
            'plant_destroy_' .. plantId
        })
        DeleteEntity(plants[plantId].object)
        
        if debugEnabled then
            print(string.format("^3[RDE | Weed Plants] Removed plant %s (Entity: %d)^7", plantId, plants[plantId].object))
        end
    end
    
    if not skipTableCleanup then
        plants[plantId] = nil
    end
end

-- 🌱 STATEBAG HANDLER (FIXED: Proper implementation)
AddStateBagChangeHandler(Config.StatebagKey, nil, function(bagName, key, value, reserved, replicated)
    -- Ignore if value is nil or empty
    if not value then
        if debugEnabled then
            print("^3[RDE | Weed Plants] Statebag cleared^7")
        end
        -- Clear all plants
        for plantId in pairs(plants) do
            removePlantObject(plantId)
        end
        return
    end
    
    if debugEnabled then
        local count = 0
        for _ in pairs(value) do count = count + 1 end
        print(string.format("^2[RDE | Weed Plants] Statebag update: %d plants^7", count))
    end

    -- Use a delay to prevent race conditions
    SetTimeout(100, function()
        SyncPlants(value)
    end)
end)

-- 🌱 Sync Plants Function
function SyncPlants(serverPlants)
    if not serverPlants then return end
    
    -- Track which plants exist in the new state
    local newPlantIds = {}
    for plantId in pairs(serverPlants) do
        newPlantIds[plantId] = true
    end

    -- Update or create plants from server data
    for plantId, plantData in pairs(serverPlants) do
        if not plants[plantId] then
            -- New plant - create it
            plants[plantId] = plantData
            plants[plantId].object = createPlantObject(plantData)
            if plants[plantId].object then
                setupPlantTarget(plantId, plantData)
            end
        else
            -- Existing plant - check if it needs updating
            if plants[plantId].stage ~= plantData.stage then
                -- Stage changed - recreate object
                updatePlantObject(plantId, plantData)
            else
                -- Just update data
                plants[plantId].timeLeft = plantData.timeLeft
                plants[plantId].data = plantData.data
            end
        end
    end

    -- Remove plants that no longer exist in statebag
    for plantId in pairs(plants) do
        if not newPlantIds[plantId] then
            removePlantObject(plantId)
        end
    end
end

-- 🌱 Direct Sync Event (Backup method)
RegisterNetEvent('rde_plants:syncPlants', function(serverPlants)
    if debugEnabled then
        local count = 0
        for _ in pairs(serverPlants) do count = count + 1 end
        print(string.format("^2[RDE | Weed Plants] Direct sync received: %d plants^7", count))
    end
    
    SyncPlants(serverPlants)
end)

-- 🌱 Helper: Item Check
local function hasItem(itemName)
    return exports.ox_inventory:GetItemCount(itemName) > 0
end

-- 🌱 Ground Check
local function checkGround()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Raycast downwards
    local rayHandle = StartShapeTestRay(coords.x, coords.y, coords.z + 0.5, coords.x, coords.y, coords.z - 2.0, 1, ped, 0)
    local _, hit, _, _, materialHash = GetShapeTestResult(rayHandle)
    
    if debugEnabled then
        print(string.format("Ground Check: Hit=%d, Material=%d", hit, materialHash))
    end
    
    if hit ~= 1 then
        lib.notify(Config.Languages[Config.DefaultLanguage].invalid_ground)
        return false
    end
    
    -- Interior Check
    if GetInteriorFromEntity(ped) ~= 0 then
        lib.notify(Config.Languages[Config.DefaultLanguage].indoors)
        return false
    end
    
    -- Water Check
    if TestVerticalProbeAgainstAllWater(coords.x, coords.y, coords.z, 0, 1.0) then
        lib.notify(Config.Languages[Config.DefaultLanguage].in_water)
        return false
    end
    
    -- Road Check
    if IsPointOnRoad(coords.x, coords.y, coords.z, 0) then
        lib.notify({
            title = GetLanguageString('error'),
            description = 'You cannot plant on roads.',
            type = 'error',
            icon = 'road'
        })
        return false
    end
    
    -- Material Check
    if Config.InvalidGroundMaterials[materialHash] then
        lib.notify(Config.Languages[Config.DefaultLanguage].invalid_ground)
        return false
    end
    
    -- Slope Check
    local groundZ, normal = GetGroundZAndNormal(coords.x, coords.y, coords.z)
    local angle = math.deg(math.acos(normal.z))

    if angle > Config.PlantingRestrictions.MaxGroundAngle then
        lib.notify(Config.Languages[Config.DefaultLanguage].too_steep)
        return false
    end
    
    -- Height Check
    local rayHandle2 = StartShapeTestRay(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z + Config.PlantingRestrictions.MinHeightClearance, 1, ped, 0)
    local _, hit2 = GetShapeTestResult(rayHandle2)

    if hit2 == 1 then
        lib.notify(Config.Languages[Config.DefaultLanguage].no_space)
        return false
    end
    
    -- Distance to other plants
    for _, plant in pairs(plants) do
        if plant and plant.coords then
            local dist = #(coords - vector3(plant.coords.x, plant.coords.y, plant.coords.z))
            if dist < Config.PlantingRestrictions.MinDistanceBetweenPlants then
                lib.notify(Config.Languages[Config.DefaultLanguage].too_close)
                return false
            end
        end
    end
    
    return true
end

-- 🌱 Event: Plant Seed
RegisterNetEvent('rde_plants:plantSeed', function()
    if not hasItem(Config.SeedItem) then
        lib.notify(Config.Languages[Config.DefaultLanguage].no_seed)
        return
    end
    
    if not checkGround() then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local groundZ = GetGroundZAndNormal(coords.x, coords.y, coords.z)
    
    lib.requestAnimDict(Config.PlantingAnimation.dict)
    TaskPlayAnim(ped, Config.PlantingAnimation.dict, Config.PlantingAnimation.anim, 8.0, -8.0, -1, Config.PlantingAnimation.flag, 0, false, false, false)
    
    if lib.progressBar({
        duration = Config.PlantingAnimation.duration,
        label = GetLanguageString('processing'),
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
    }) then
        ClearPedTasks(ped)
        TriggerServerEvent('rde_plants:createPlant', { x = coords.x, y = coords.y, z = groundZ })
    else
        ClearPedTasks(ped)
        lib.notify({
            title = GetLanguageString('cancelled'),
            description = 'Planting cancelled',
            type = 'error'
        })
    end
end)

-- 🌱 Event: Harvest Plant
RegisterNetEvent('rde_plants:harvestPlant', function(plantId)
    local plant = plants[plantId]
    if not plant then
        if debugEnabled then print(string.format("^1[RDE | Weed Plants] Harvest failed: Plant %s not found^7", plantId)) end
        return
    end
    
    if plant.stage ~= 4 then
        lib.notify(Config.Languages[Config.DefaultLanguage].not_ready)
        return
    end
    
    if not hasItem(Config.HarvestTool) then
        lib.notify(Config.Languages[Config.DefaultLanguage].no_tool)
        return
    end
    
    local ped = PlayerPedId()
    lib.requestAnimDict(Config.HarvestingAnimation.dict)
    
    local success = lib.progressBar({
        duration = Config.HarvestingAnimation.duration,
        label = GetLanguageString('processing'),
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = Config.HarvestingAnimation.dict, clip = Config.HarvestingAnimation.anim },
    })
    
    ClearPedTasks(ped)
    
    if success then
        TriggerServerEvent('rde_plants:harvestComplete', plantId)
    else
        lib.notify({
            title = GetLanguageString('cancelled'),
            description = 'Harvest cancelled',
            type = 'error'
        })
    end
end)

-- 🌱 3D Text Rendering
local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function DrawPlantInfo(plant)
    if not plant or not plant.object or not DoesEntityExist(plant.object) then return end

    local stage = Config.GrowthStages[plant.stage]
    if not stage then return end
    
    local coords = GetEntityCoords(plant.object)
    local timeLeft = math.max(0, math.ceil((plant.timeLeft or 0) / 60))

    local text = string.format("%s\n%s",
        GetLanguageString(stage.label),
        GetLanguageString('minutes_remaining', timeLeft)
    )
    
    if Config.Growth.enableWeather and plant.stage < 4 and plant.data then
        local weatherBonus = plant.data.weather_bonus or 0
        if weatherBonus > 0 then
            text = text .. string.format("\n" .. GetLanguageString('weather_boost'), math.floor(weatherBonus * 100))
        end
    end
    
    DrawText3D(coords.x, coords.y, coords.z + 1.0, text)
end

-- 🌱 Main Thread for 3D Text
CreateThread(function()
    while true do
        local sleep = 1000
        
        if Config.ShowPlantInfo then
            local playerCoords = GetEntityCoords(PlayerPedId())
            for _, plant in pairs(plants) do
                if plant and plant.object and DoesEntityExist(plant.object) then
                    local plantCoords = GetEntityCoords(plant.object)
                    local distance = #(playerCoords - plantCoords)

                    if distance < Config.Distances.drawText then
                        sleep = 0
                        DrawPlantInfo(plant)
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- 🌱 Player Loaded (ox_core v3)
AddEventHandler('ox:playerLoaded', function(playerId, userId, charId)
    playerLoaded = true
    
    if debugEnabled then print("^2[RDE | Weed Plants] Player loaded, waiting for sync...^7") end
    
    -- Multiple sync attempts for reliability
    SetTimeout(1000, function()
        TriggerServerEvent('rde_plants:requestSync')
    end)
    
    SetTimeout(3000, function()
        TriggerServerEvent('rde_plants:requestSync')
    end)
    
    -- Check GlobalState directly as fallback
    SetTimeout(5000, function()
        local globalPlants = GlobalState[Config.StatebagKey]
        if globalPlants then
            if debugEnabled then
                local count = 0
                for _ in pairs(globalPlants) do count = count + 1 end
                print(string.format("^2[RDE | Weed Plants] Loading from GlobalState: %d plants^7", count))
            end
            SyncPlants(globalPlants)
        end
    end)
end)

AddEventHandler('ox:playerLogout', function(playerId, userId, charId)
    playerLoaded = false
    -- Clear all plants on logout
    for plantId in pairs(plants) do
        removePlantObject(plantId)
    end
end)

-- 🌱 Resource Start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if debugEnabled then print("^2[RDE | Weed Plants] Resource started, requesting sync...^7") end
        
        -- Multiple sync attempts
        SetTimeout(2000, function()
            TriggerServerEvent('rde_plants:requestSync')
        end)
        
        SetTimeout(4000, function()
            TriggerServerEvent('rde_plants:requestSync')
        end)
        
        -- Direct GlobalState check as fallback
        SetTimeout(6000, function()
            local globalPlants = GlobalState[Config.StatebagKey]
            if globalPlants then
                if debugEnabled then
                    local count = 0
                    for _ in pairs(globalPlants) do count = count + 1 end
                    print(string.format("^2[RDE | Weed Plants] Resource start - loading %d plants from GlobalState^7", count))
                end
                SyncPlants(globalPlants)
            end
        end)
    end
end)

-- 🌱 Resource Stop - Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for plantId in pairs(plants) do
            removePlantObject(plantId)
        end
    end
end)

-- 🌱 Debug Command
if Config.Debug then
    RegisterCommand('debugplants', function()
        print("^3=== CLIENT PLANTS DEBUG ===^7")
        local count = 0
        for _ in pairs(plants) do count = count + 1 end
        print(string.format("Total plants: %d", count))
        for id, plant in pairs(plants) do
            print(string.format("  %s: Stage=%d, Entity=%s, Exists=%s",
                id,
                plant.stage,
                tostring(plant.object),
                tostring(DoesEntityExist(plant.object or 0))
            ))
        end
        
        -- Check GlobalState
        local globalPlants = GlobalState[Config.StatebagKey]
        local globalCount = 0
        if globalPlants then
            for _ in pairs(globalPlants) do globalCount = globalCount + 1 end
        end
        print(string.format("GlobalState plants: %d", globalCount))
    end, false)
end
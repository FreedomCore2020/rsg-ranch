local RSGCore = exports['rsg-core']:GetCoreObject()
local SpawnedAnimals = {}
local isBusy = false
local isFollowing = false

-------------------------------------------------------------------------------------------
-- prompts and blips
-------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    for _, v in pairs(Config.RanchLocations) do
        exports['rsg-core']:createPrompt(v.ranchid, v.coords, RSGCore.Shared.Keybinds[Config.Keybind], 'Open '..v.name, {
            type = 'client',
            event = 'rsg-ranch:client:mainmenu',
            args = { v.job },
        })
        if v.showblip == true then
            local RanchMenuBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.coords)
            SetBlipSprite(RanchMenuBlip,  joaat(Config.RanchBlip.blipSprite), true)
            SetBlipScale(RanchMenuBlip, Config.RanchBlip.blipScale)
            Citizen.InvokeNative(0x9CB1A1623062F402, RanchMenuBlip, Config.RanchBlip.blipName)
        end
    end
end)
-------------------------------------------------------------------------------------------

RegisterNetEvent('rsg-ranch:client:mainmenu', function(job)
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local playerjob = PlayerData.job.name
    jobaccess = job
    if playerjob == jobaccess then
        lib.registerContext({
            id = 'ranch_mainmenu',
            title = 'Ranch Menu',
            options = {
                {
                    title = 'Ranch Boss Menu',
                    description = 'access boss menu',
                    icon = 'fa-solid fa-hat-cowboy',
                    event = 'rsg-bossmenu:client:mainmenu',
                    arrow = true
                },
            }
        })
        lib.showContext('ranch_mainmenu')
    else
        lib.notify({ title = 'Access Error', description = 'you don\'t have access to this!', type = 'error' })
    end
end)

-- new animal deploy
RegisterNetEvent('rsg-ranch:client:newanimal')
AddEventHandler('rsg-ranch:client:newanimal', function(animal, hash, product)
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local playerjob = PlayerData.job.name

    for i, v in ipairs(Config.AuthorisedJobs) do
        if v ~= playerjob then
            lib.notify({ title = 'Not Allowed', description = 'only rancher\'s are able to do this!', type = 'error' })
            return
        end
    end

    local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 3.0, 0.0)
    local heading = GetEntityHeading(PlayerPedId())
    local ped = PlayerPedId()

    if not IsPedInAnyVehicle(PlayerPedId(), false) and not isBusy then
        isBusy = true
        local anim1 = `WORLD_HUMAN_CROUCH_INSPECT`
        FreezeEntityPosition(ped, true)
        TaskStartScenarioInPlace(ped, anim1, 0, true)
        Wait(10000)
        ClearPedTasks(ped)
        FreezeEntityPosition(ped, false)
        --print(animal, pos, heading, hash, playerjob)
        TriggerServerEvent('rsg-ranch:server:newanimal', animal, pos, heading, hash, playerjob, product)
        isBusy = false
        return
    end

    lib.notify({ title = 'Problem', description = 'can\'t place it while in a vehicle!', type = 'error' })

    Wait(3000)
end)

-- update animals
RegisterNetEvent('rsg-ranch:client:updateAnimalData')
AddEventHandler('rsg-ranch:client:updateAnimalData', function(data)
    Config.RanchAnimals = data
end)

-- spawn ranch animals
Citizen.CreateThread(function()
    while true do
        Wait(150)

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local InRange = false

        for i = 1, #Config.RanchAnimals do
        
            local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.RanchAnimals[i].x, Config.RanchAnimals[i].y, Config.RanchAnimals[i].z, true)
            
            if dist >= 50.0 then goto continue end

            local hasSpawned = false
            InRange = true

            for z = 1, #SpawnedAnimals do
                local p = SpawnedAnimals[z]
                if p.id == Config.RanchAnimals[i].id then
                    hasSpawned = true
                end
            end

            if hasSpawned then goto continue end

            local modelHash = Config.RanchAnimals[i].hash
            local data = {}
            
            if not HasModelLoaded(modelHash) then
                RequestModel(modelHash)
                while not HasModelLoaded(modelHash) do
                    Wait(1)
                end
            end
            
            data.id = Config.RanchAnimals[i].id
            data.obj = CreatePed(modelHash, Config.RanchAnimals[i].x, Config.RanchAnimals[i].y, Config.RanchAnimals[i].z -1.2, true, true, false)
            SetEntityHeading(data.obj, Config.RanchAnimals[i].h)
            Citizen.InvokeNative(0x77FF8D35EEC6BBC4, data.obj, 0, false)
            Citizen.InvokeNative(0xE054346CA3A0F315, data.obj, Config.RanchAnimals[i].x, Config.RanchAnimals[i].y, Config.RanchAnimals[i].z, 50.0, tonumber(1077936128), tonumber(1086324736), 1)
            Citizen.InvokeNative(0x23f74c2fda6e7c61, -1749618580, data.obj)
            SetEntityAsMissionEntity(data.obj, true)
            SetModelAsNoLongerNeeded(data.obj)

            SpawnedAnimals[#SpawnedAnimals + 1] = data
            hasSpawned = false
            
            -- create animal target
            exports['rsg-target']:AddTargetEntity(data.obj, {
                options = {
                    {
                        type = "client",
                        event = 'rsg-ranch:client:animalinfo',
                        id = Config.RanchAnimals[i].id,
                        icon = "far fa-eye",
                        label = 'Check Animal',
                    },
                    {
                        type = "client",
                        event = 'rsg-ranch:client:animalfollow',
                        entity = data.obj,
                        icon = "far fa-eye",
                        label = 'Follow Toggle'
                    }
                },
                distance = Config.AnimalTargetDistance
            })

            ::continue::
        end

        if not InRange then
            Wait(5000)
        end
    end
end)

RegisterNetEvent('rsg-ranch:client:animalinfo', function(data)
    RSGCore.Functions.TriggerCallback('rsg-ranch:server:getanimaldata', function(result)
        local animals = json.decode(result[1].animals)
        lib.registerContext({
            id = 'ranch_animalinfo',
            title = 'Animal Info',
            options = {
                {
                    title = 'ID: '..animals.id,
                    description = animals.animal..' id',
                    icon = 'fa-solid fa-fingerprint',
                },
                {
                    title = 'Age: '..tonumber(animals.age),
                    description = animals.animal..' age',
                    icon = 'fa-solid fa-paw',
                },
                {
                    title = 'Health: '..animals.health,
                    progress = animals.health,
                    colorScheme = 'green',
                    description = animals.animal..' health',
                    icon = 'fa-solid fa-heart-pulse',
                },
                {
                    title = 'Product Progress : '..animals.product,
                    progress = animals.product,
                    colorScheme = 'green',
                    description = animals.animal..' '..animals.productoutput..' production in progress',
                    icon = 'fa-solid fa-bars-progress',
                },
                {
                    title = 'Feed Animal',
                    description = 'feed animal to improve health',
                    icon = 'fa-solid fa-wheat-awn',
                    event = 'rsg-ranch:client:feedanimal',
                    args = {
                        animalid = animals.id,
                        animalhealth = animals.health,
                        animaltype = animals.animal
                    },
                    arrow = true
                },
                {
                    title = 'Colect Product',
                    description = 'collect product from animal',
                    icon = 'fa-solid fa-wheat-awn',
                    event = 'rsg-ranch:client:collectproduct',
                    args = {
                        ranchid = animals.ranchid,
						animalid = animals.id,
                        animalproduct = animals.product,
						animalproductoutput = animals.productoutput,
                        animaltype = animals.animal
                    },
                    arrow = true
                },
            }
        })
        lib.showContext('ranch_animalinfo')
    end, data.id)
end)

-- feed animal / improve health
RegisterNetEvent('rsg-ranch:client:feedanimal', function(data)
    if data.animalhealth <= 100 then
        TriggerServerEvent('rsg-ranch:server:feedanimal', data.animalid, data.animalhealth, data.animaltype)
    else
        lib.notify({ title = 'Animal Full', description = 'animal does not require any food!', type = 'inform' })
    end
end)

-- collect product
RegisterNetEvent('rsg-ranch:client:collectproduct', function(data)
    if data.animalproduct >= 100 then
        TriggerServerEvent('rsg-ranch:server:collectproduct', data.ranchid, data.animalid, data.animalproduct, data.animalproductoutput, data.animaltype)
    else
        lib.notify({ title = 'Product Not Ready', description = 'product not ready to collect yet!', type = 'inform' })
    end
end)

-- set new animal position and handle animal being killed
Citizen.CreateThread(function()
    while true do
        for i = 1, #SpawnedAnimals do
            local animals = SpawnedAnimals[i].obj
            local animalid = SpawnedAnimals[i].id
            local pos = GetEntityCoords(animals)
            if IsPedDeadOrDying(animals, true) then
                TriggerServerEvent('rsg-ranch:server:animalkilled', animalid)
            else
                TriggerServerEvent('rsg-ranch:server:updateposition', animalid, pos.x, pos.y, pos.z)
            end
        end
        Wait(5000)
    end
end)

-- set animal to follow you
RegisterNetEvent('rsg-ranch:client:animalfollow')
AddEventHandler('rsg-ranch:client:animalfollow', function(data)
    if IsPedDeadOrDying(data.entity, true) then
        lib.notify({ title = 'Animal Dead', description = 'this animal is dead!', type = 'error' })
        return 
    end
    if isFollowing == false then
        isFollowing = true
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)
        local animalOffset = vector3(0.0, 2.0, 0.0) 
        ClearPedTasks(data.entity)
        TaskFollowToOffsetOfEntity(data.entity, player, animalOffset.x, animalOffset.y, animalOffset.z, 1.0, -1, 0.0, 1)
    else
        isFollowing = false
        local x,y,z = table.unpack(GetEntityCoords(data.entity))
        Citizen.InvokeNative(0xE054346CA3A0F315, data.entity, x, y, z, 50.0, tonumber(1077936128), tonumber(1086324736), 1)
    end
end)

-------------------------------------------------------------------------------

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for i = 1, #SpawnedAnimals do
        local animals = SpawnedAnimals[i].obj

        SetEntityAsMissionEntity(animals, false)
        FreezeEntityPosition(animals, false)
        DeletePed(animals)
    end
end)

-------------------------------------------------------------
-- testing stuff
-------------------------------------------------------------

--[[
RegisterNetEvent('rsg-ranch:client:testoutput', function()

    for i = 1, #Config.RanchAnimals do
        id = Config.RanchAnimals[i].id
        ranchid = Config.RanchAnimals[i].ranchid
        animal = Config.RanchAnimals[i].animal
        hash = Config.RanchAnimals[i].hash
        borntime = Config.RanchAnimals[i].born
        health = Config.RanchAnimals[i].health
        product = Config.RanchAnimals[i].product
        posx = Config.RanchAnimals[i].x
        posy = Config.RanchAnimals[i].y
        posz = Config.RanchAnimals[i].z
        posh = Config.RanchAnimals[i].h
        
        print('id '..id)
        print('ranchid '..ranchid)
        print('animal '..animal)
        print('hash '..hash)
        print('borntime '..borntime)
        print('health '..health)
        print('product '..product)
        print('posx '..posx)
        print('posy '..posy)
        print('posz '..posz)
        print('posh '..posh)
    end

end)
--]]
local RSGCore = exports['rsg-core']:GetCoreObject()
local SpawnedAnimals = {}
local isBusy = false

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
                {
                    title = 'Test Output',
                    description = 'access boss menu',
                    icon = 'fa-solid fa-hat-cowboy',
                    event = 'rsg-ranch:client:testoutput',
                    arrow = true
                },
            }
        })
        lib.showContext('ranch_mainmenu')
    else
        RSGCore.Functions.Notify('no access!', 'error')
    end
end)

-- new animal deploy
RegisterNetEvent('rsg-ranch:client:newanimal')
AddEventHandler('rsg-ranch:client:newanimal', function(animal, hash)
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local playerjob = PlayerData.job.name

    for i, v in ipairs(Config.AuthorisedJobs) do
        if v ~= playerjob then
            RSGCore.Functions.Notify('you are not a rancher!', 'error', 5000)
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
        TriggerServerEvent('rsg-ranch:server:newanimal', animal, pos, heading, hash, playerjob)
        isBusy = false
        return
    end

    RSGCore.Functions.Notify('can\'t place it while in a vehicle!', 'error', 5000)

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
                        event = 'rsg-ranch:client:testtarget',
                        id = Config.RanchAnimals[i].id,
                        ranchid = Config.RanchAnimals[i].ranchid,
                        animal = Config.RanchAnimals[i].animal,
                        hash = Config.RanchAnimals[i].hash,
                        borntime = Config.RanchAnimals[i].borntime,
                        icon = "far fa-eye",
                        label = 'Check Animal',
                        distance = 3.0
                    }
                }
            })

            ::continue::
        end

        if not InRange then
            Wait(5000)
        end
    end
end)

RegisterNetEvent('rsg-ranch:client:testtarget', function(data)
    print(data.id, data.ranchid, data.animal, data.borntime)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for i = 1, #SpawnedAnimals do
        local animals = SpawnedAnimals[i].obj

        SetEntityAsMissionEntity(animals, false)
        FreezeEntityPosition(animals, false)
        DeletePed(animals)
    end
end)



--[[
RegisterNetEvent('rsg-ranch:client:testoutput', function()

    for i = 1, #Config.RanchAnimals do
        id = Config.RanchAnimals[i].id
        ranchid = Config.RanchAnimals[i].ranchid
        animal = Config.RanchAnimals[i].animal
        hash = Config.RanchAnimals[i].hash
        borntime = Config.RanchAnimals[i].borntime
        posx = Config.RanchAnimals[i].x
        posy = Config.RanchAnimals[i].y
        posz = Config.RanchAnimals[i].z
        posh = Config.RanchAnimals[i].h
        
        print('id '..id)
        print('ranchid '..ranchid)
        print('animal '..animal)
        print('hash '..hash)
        print('borntime '..borntime)
        print('posx '..posx)
        print('posy '..posy)
        print('posz '..posz)
        print('posh '..posh)
    end

end)
--]]
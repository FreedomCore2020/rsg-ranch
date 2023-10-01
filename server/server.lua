local RSGCore = exports['rsg-core']:GetCoreObject()
local AnimalsLoaded = false

-----------------------------------------------------------------------
-- version checker
-----------------------------------------------------------------------
local function versionCheckPrint(_type, log)
    local color = _type == 'success' and '^2' or '^1'

    print(('^5['..GetCurrentResourceName()..']%s %s^7'):format(color, log))
end

local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/Rexshack-RedM/rsg-ranch/main/version.txt', function(err, text, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')

        if not text then 
            versionCheckPrint('error', 'Currently unable to run a version check.')
            return 
        end

        --versionCheckPrint('success', ('Current Version: %s'):format(currentVersion))
        --versionCheckPrint('success', ('Latest Version: %s'):format(text))
        
        if text == currentVersion then
            versionCheckPrint('success', 'You are running the latest version.')
        else
            versionCheckPrint('error', ('You are currently running an outdated version, please update to version %s'):format(text))
        end
    end)
end

-----------------------------------------------------------------------

-- use animal purchase
RSGCore.Functions.CreateUseableItem("cow", function(source)
    local src = source
    TriggerClientEvent('rsg-ranch:client:newanimal', src, 'cow', `A_C_Cow`)
end)

-----------------------------------------------------------------------

-- update animal data
CreateThread(function()
    while true do
        Wait(5000)
        if AnimalsLoaded then
            TriggerClientEvent('rsg-ranch:client:updateAnimalData', -1, Config.RanchAnimals)
        end
    end
end)

CreateThread(function()
    TriggerEvent('rsg-gangcamp:server:getAnimals')
    AnimalsLoaded = true
end)

-- get props
RegisterServerEvent('rsg-gangcamp:server:getAnimals')
AddEventHandler('rsg-gangcamp:server:getAnimals', function()
    local result = MySQL.query.await('SELECT * FROM player_ranch')

    if not result[1] then return end

    for i = 1, #result do
        local animalData = json.decode(result[i].animals)
        print('loading '..animalData.animal..' prop with ID: '..animalData.id)
        table.insert(Config.RanchAnimals, animalData)
    end
end)

-----------------------------------------------------------------------

-- new prop
RegisterServerEvent('rsg-ranch:server:newanimal')
AddEventHandler('rsg-ranch:server:newanimal', function(animal, pos, heading, hash, playerjob)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local animalid = math.random(111111, 999999)
    local AnimalData =
    {
        id = animalid,
        animal = animal,
		health = 100,
        x = pos.x,
        y = pos.y,
        z = pos.z,
        h = heading,
        hash = hash,
        ranchid = playerjob,
        borntime = os.time()
    }

    local AnimalCount = 0

    for _, v in pairs(Config.RanchAnimals) do
        if v.playerjob == Player.PlayerData.playerjob then
            AnimalCount = AnimalCount + 1
        end
    end

    if AnimalCount >= Config.MaxAnimalCount then
        TriggerClientEvent('RSGCore:Notify', src, 'you have the maximum animals alowed!', 'error')
    else
        table.insert(Config.RanchAnimals, AnimalData)
        Player.Functions.RemoveItem(animal, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[animal], "remove")
        TriggerEvent('rsg-ranch:server:saveAnimal', AnimalData, playerjob)
        TriggerEvent('rsg-ranch:server:updateAnimals')
    end
end)

RegisterServerEvent('rsg-ranch:server:saveAnimal')
AddEventHandler('rsg-ranch:server:saveAnimal', function(AnimalData, playerjob)
    local datas = json.encode(AnimalData)

    MySQL.Async.execute('INSERT INTO player_ranch (animals, ranchid) VALUES (@animals, @ranchid)',
    {
        ['@animals'] = datas,
        ['@ranchid'] = playerjob,
    })
end)

RegisterServerEvent('rsg-ranch:server:updateAnimals')
AddEventHandler('rsg-ranch:server:updateAnimals', function()
    local src = source
    TriggerClientEvent('rsg-ranch:client:updateAnimalData', src, Config.RanchAnimals)
end)

--[[
--------------------------------------------------------------------------------------------------
-- gangcamp upkeep system
--------------------------------------------------------------------------------------------------
UpkeepInterval = function()
    local result = MySQL.query.await('SELECT * FROM player_ranch')

    if not result then goto continue end

    for i = 1, #result do
		local animalData = json.decode(result[i].animals)
        if animalData.health >= 1 then
		
            local healthadjust = (animalData.health - 1)
			local id = animalData.id
            MySQL.update('UPDATE player_ranch SET credit = ? WHERE propid = ?', { creditadjust, row.propid })
			MySQL.Async.execute("UPDATE players SET `animals` = ? WHERE `id`= ? AND `license`= ?", {json.encode(Charinfo), citizenid, license})
        else
            MySQL.update('DELETE FROM player_props WHERE propid = ?', {row.propid})

            if Config.PurgeStorage then
                MySQL.update('DELETE FROM stashitems WHERE stash = ?', { 'gang_'..row.gang })
            end
            
            if Config.ServerNotify == true then
                print('object with the id of '..row.propid..' owned by the gang '..row.gang.. ' was deleted')
            end

            TriggerEvent('rsg-log:server:CreateLog', 'gangmenu', 'Gang Object Lost', 'red', row.gang..' prop with ID: '..row.propid..' has been lost due to non maintenance!')
        end
    end

    ::continue::

    print('gangcamp upkeep cycle complete')

    SetTimeout(Config.BillingCycle * (60 * 60 * 1000), UpkeepInterval) -- hours
    --SetTimeout(Config.BillingCycle * (60 * 1000), UpkeepInterval) -- mins (for testing)
end

SetTimeout(Config.BillingCycle * (60 * 60 * 1000), UpkeepInterval) -- hours
--SetTimeout(Config.BillingCycle * (60 * 1000), UpkeepInterval) -- mins (for testing)
--]]

--------------------------------------------------------------------------------------------------
-- start version check
--------------------------------------------------------------------------------------------------
CheckVersion()
local RSGCore = exports['rsg-core']:GetCoreObject()

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

-- new prop
RegisterServerEvent('rsg-ranch:server:newanimal')
AddEventHandler('rsg-ranch:server:newanimal', function(animal, pos, heading, hash, playerjob)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local animalid = math.random(111111, 999999)
    local animaldata =
    {
        id = animalid,
        animal = animal,
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
        TriggerEvent('rsg-ranch:server:saveAnimal', animaldata, playerjob)
        TriggerEvent('rsg-ranch:server:updateAnimal')
    end
end)

RegisterServerEvent('rsg-ranch:server:saveAnimal')
AddEventHandler('rsg-ranch:server:saveAnimal', function(animaldata, playerjob)
    local datas = json.encode(animaldata)

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

--------------------------------------------------------------------------------------------------
-- start version check
--------------------------------------------------------------------------------------------------
CheckVersion()
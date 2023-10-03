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

-- use animal cow purchase
RSGCore.Functions.CreateUseableItem("cow", function(source)
    local src = source
    TriggerClientEvent('rsg-ranch:client:newanimal', src, 'cow', `A_C_Cow`)
end)

-- use animal sheep purchase
RSGCore.Functions.CreateUseableItem("sheep", function(source)
    local src = source
    TriggerClientEvent('rsg-ranch:client:newanimal', src, 'sheep', `a_c_sheep_01`)
end)

-----------------------------------------------------------------------

-- get all prop data
RSGCore.Functions.CreateCallback('rsg-ranch:server:getanimaldata', function(source, cb, animalid)
    MySQL.query('SELECT * FROM ranch_animals WHERE animalid = ?', {animalid}, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
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

-- get animals
RegisterServerEvent('rsg-gangcamp:server:getAnimals')
AddEventHandler('rsg-gangcamp:server:getAnimals', function()
    local result = MySQL.query.await('SELECT * FROM ranch_animals')

    if not result[1] then return end

    for i = 1, #result do
        local animalData = json.decode(result[i].animals)
        print('loading '..animalData.animal..' with ID: '..animalData.id)
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
        product = 0,
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
    
        TriggerClientEvent('ox_lib:notify', src, {title = 'Maximum Animals', description = 'you have the maximum animals alowed!', type = 'inform' })
        
    else
        table.insert(Config.RanchAnimals, AnimalData)
        Player.Functions.RemoveItem(animal, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[animal], "remove")
        TriggerEvent('rsg-ranch:server:saveAnimal', AnimalData, playerjob, animalid)
        TriggerEvent('rsg-ranch:server:updateAnimals')
    end
end)

RegisterServerEvent('rsg-ranch:server:saveAnimal')
AddEventHandler('rsg-ranch:server:saveAnimal', function(AnimalData, playerjob, animalid)
    local datas = json.encode(AnimalData)

    MySQL.Async.execute('INSERT INTO ranch_animals (animals, ranchid, animalid) VALUES (@animals, @ranchid, @animalid)',
    {
        ['@animals'] = datas,
        ['@ranchid'] = playerjob,
        ['@animalid'] = animalid,
    })
end)

RegisterServerEvent('rsg-ranch:server:updateAnimals')
AddEventHandler('rsg-ranch:server:updateAnimals', function()
    local src = source
    TriggerClientEvent('rsg-ranch:client:updateAnimalData', src, Config.RanchAnimals)
end)

-- feed animal
RegisterNetEvent('rsg-ranch:server:feedanimal', function(animalid, animalhealth, animaltype)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local result = MySQL.query.await('SELECT * FROM ranch_animals WHERE animalid = ?', {animalid})
    
    for i = 1, #result do
        local id = result[i].id
        local animalData = json.decode(result[i].animals)
        -- update animal health
        local healthadjust = (animalData.health + Config.AnimalFeedAdd)
        animalData.health = healthadjust
        MySQL.update("UPDATE ranch_animals SET `animals` = ? WHERE `id` = ?", {json.encode(animalData), id})
        Player.Functions.RemoveItem('animalfeed', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['animalfeed'], "remove")
        TriggerClientEvent('ox_lib:notify', src, {title = 'Animals Fed', description = 'animal feeding was successful!', type = 'inform' })
    end
end)

-- colect product from animal
RegisterNetEvent('rsg-ranch:server:collectproduct', function(animalid, product, animaltype)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    local result = MySQL.query.await('SELECT * FROM ranch_animals WHERE animalid = ?', {animalid})

    for i = 1, #result do
        local id = result[i].id
        local animalData = json.decode(result[i].animals)
        -- reset animal product
        animalData.product = 0
        MySQL.update("UPDATE ranch_animals SET `animals` = ? WHERE `id` = ?", {json.encode(animalData), id})
        if animaltype == 'cow' then
            Player.Functions.AddItem('milk', 1)
            TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['milk'], "add")
            TriggerClientEvent('ox_lib:notify', src, {title = 'Milk Produced', description = 'your cow produced some milk!', type = 'inform' })
        end
        if animaltype == 'sheep' then
            Player.Functions.AddItem('wool', 1)
            TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['wool'], "add")
            TriggerClientEvent('ox_lib:notify', src, {title = 'Wool Produced', description = 'your sheep produced some wool!', type = 'inform' })
        end
    end

end)

-- update new animal position to database
RegisterNetEvent('rsg-ranch:server:updateposition', function(animalid, posx, posy, posz)

    local result = MySQL.query.await('SELECT * FROM ranch_animals')

    if not result then goto continue end

    for i = 1, #result do
        local id = result[i].id
        local animalData = json.decode(result[i].animals)
        
        -- set position
        animalData.x = posx
        animalData.y = posy
        animalData.z = posz
        
        MySQL.update("UPDATE ranch_animals SET `animals` = ? WHERE `id` = ?", {json.encode(animalData), id})    
    end

    ::continue::
end)

-- if animal is killed it will be removed from the database
RegisterServerEvent('rsg-ranch:server:animalkilled')
AddEventHandler('rsg-ranch:server:animalkilled', function(animalid)
    MySQL.update('DELETE FROM ranch_animals WHERE animalid = ?', {animalid})
    TriggerEvent('rsg-log:server:CreateLog', 'ranch', 'Ranch Animal Killed', 'red', 'animal with the branding id of '..animalid..' was killed!')
end)

--------------------------------------------------------------------------------------------------
-- ranch upkeep system
--------------------------------------------------------------------------------------------------
UpkeepInterval = function()
    local result = MySQL.query.await('SELECT * FROM ranch_animals')

    if not result then goto continue end

    for i = 1, #result do
        local id = result[i].id
        local animalData = json.decode(result[i].animals)

        if animalData.health > 1 then
            -- update animal health
            local healthadjust = (animalData.health - Config.HealthRemovePerCycle)
            animalData.health = healthadjust
            MySQL.update("UPDATE ranch_animals SET `animals` = ? WHERE `id` = ?", {json.encode(animalData), id})
        else
            print('animal '..animalData.animal..' with the id of '..animalData.id..' owned by ranch '..animalData.ranchid..' died!')
            MySQL.update('DELETE FROM ranch_animals WHERE id = ?', {id})
            TriggerEvent('rsg-log:server:CreateLog', 'ranch', 'Ranch Animal Died', 'red', 'animal '..animalData.animal..' with the id of '..animalData.id..' owned by ranch '..animalData.ranchid.. ' died!')
        end
        
        if animalData.product < 100 then
            -- update animal product
            local productadjust = (animalData.product + Config.ProductAddPerCycle)
            animalData.product = productadjust
            MySQL.update("UPDATE ranch_animals SET `animals` = ? WHERE `id` = ?", {json.encode(animalData), id})
        end
        
    end

    ::continue::
    
    TriggerEvent('rsg-ranch:server:updateAnimals')
    print('animal check cycle complete')

    SetTimeout(Config.CheckCycle * (60 * 1000), UpkeepInterval)
end

SetTimeout(Config.CheckCycle * (60 * 1000), UpkeepInterval)

--------------------------------------------------------------------------------------------------
-- start version check
--------------------------------------------------------------------------------------------------
CheckVersion()

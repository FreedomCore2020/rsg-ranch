local RSGCore = exports['rsg-core']:GetCoreObject()
local CollectedPoop = {}

-----------------------------------------------------------------------------------

-- give item
RegisterServerEvent('rsg-ranch:server:giveitem')
AddEventHandler('rsg-ranch:server:giveitem', function(item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[item], "add")
end)

-----------------------------------------------------------------------------------

-- collected poop
RegisterNetEvent('rsg-farmer:server:collectedpoop')
AddEventHandler('rsg-farmer:server:collectedpoop', function(coords)
    local exists = false
    
    for i = 1, #CollectedPoop do
        local poo = CollectedPoop[i]
        if poo == coords then
            exists = true

            break
        end
    end

    if not exists then
        CollectedPoop[#CollectedPoop + 1] = coords
    end
end)

-- check collected poop
RSGCore.Functions.CreateCallback('rsg-ranch:server:checkcollectedpoop', function(source, cb, coords)
    local exists = false
	
    for i = 1, #CollectedPoop do
        local poo = CollectedPoop[i]

        if poo == coords then
            exists = true
            break
        end
    end
    cb(exists)
	
end)

-----------------------------------------------------------------------------------

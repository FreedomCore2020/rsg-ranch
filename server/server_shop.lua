local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterServerEvent('rsg-ranch:server:ranchshopGetShopItems')
AddEventHandler('rsg-ranch:server:ranchshopGetShopItems', function(data)
    local src = source
    MySQL.query('SELECT * FROM ranch_shop_stock WHERE shopid = ?', {data.id}, function(data2)
        MySQL.query('SELECT * FROM ranch_shop WHERE shopid = ?', {data.id}, function(data3)
            TriggerClientEvent('rsg-ranch:client:ReturnStoreItems', src, data2, data3)
        end)
    end)
end)

RSGCore.Functions.CreateCallback('rsg-ranch:server:ranchshopS', function(source, cb, currentranchshop)
    MySQL.query('SELECT * FROM ranch_shop WHERE shopid = ?', {currentranchshop}, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

-- get ranch stock items
RSGCore.Functions.CreateCallback('rsg-ranch:server:ranchStock', function(source, cb, playerjob)
    MySQL.query('SELECT * FROM ranch_stock WHERE jobaccess = ?', { playerjob }, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

-- refill ranchshop from ranch stock
RegisterServerEvent('rsg-ranch:server:ranchshopInvReFill')
AddEventHandler('rsg-ranch:server:ranchshopInvReFill', function(location, item, qt, price, job)
    local src = source
    MySQL.query('SELECT * FROM ranch_shop_stock WHERE shopid = ? AND items = ?',{location, item} , function(result)
        if result[1] ~= nil then
            local stockadd = result[1].stock + tonumber(qt)
            MySQL.update('UPDATE ranch_shop_stock SET stock = ?, price = ? WHERE shopid = ? AND items = ?',{stockadd, price, location, item})
        else
            MySQL.insert('INSERT INTO ranch_shop_stock (`shopid`, `items`, `stock`, `price`) VALUES (?, ?, ?, ?);',{location, item, qt, price})
        end
    end)
    MySQL.query('SELECT * FROM ranch_stock WHERE jobaccess = ? AND item = ?',{job, item} , function(result)
        if result[1] ~= nil then
            local stockremove = result[1].stock - tonumber(qt)
            MySQL.update('UPDATE ranch_stock SET stock = ? WHERE jobaccess = ? AND item = ?',{stockremove, job, item})
        else
            MySQL.insert('INSERT INTO ranch_stock (`jobaccess`, `item`, `stock`) VALUES (?, ?, ?);', {job, item, qt})
        end
    end)
    TriggerClientEvent('RSGCore:Notify', src, Lang:t('lang_s26'), 'success')
end)

RegisterServerEvent('rsg-ranch:server:ranchshopPurchaseItem')
AddEventHandler('rsg-ranch:server:ranchshopPurchaseItem', function(location, item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local Playercid = Player.PlayerData.citizenid
    
    MySQL.query('SELECT * FROM ranch_shop_stock WHERE shopid = ? AND items = ?',{location, item} , function(data)
        local stock = data[1].stock - amount
        local price = data[1].price * amount   
        local currentMoney = Player.Functions.GetMoney('cash')
        if price <= currentMoney then
            MySQL.update("UPDATE ranch_shop_stock SET stock=@stock WHERE shopid=@location AND items=@item", {['@stock'] = stock, ['@location'] = location, ['@item'] = item}, function(count)
                if count > 0 then
                    Player.Functions.RemoveMoney("cash", price, "market")
                    Player.Functions.AddItem(item, amount)
                    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[item], "add")
                    MySQL.query("SELECT * FROM ranch_shop WHERE shopid=@location", { ['@location'] = location }, function(data2)
                        local moneymarket = data2[1].money + price
                        MySQL.update('UPDATE ranch_shop SET money = ? WHERE shopid = ?',{moneymarket, location})
                    end)
                    TriggerClientEvent('RSGCore:Notify', src, Lang:t('lang_s27').." "..amount.."x "..RSGCore.Shared.Items[item].label, 'success')
                end
            end)
        else 
            TriggerClientEvent('RSGCore:Notify', src, Lang:t('lang_s28'), 'error')
        end
    end)
end)

RSGCore.Functions.CreateCallback('rsg-ranch:server:ranchshopGetMoney', function(source, cb, currentranchshop)
    MySQL.query('SELECT * FROM ranch_shop WHERE shopid = ?', {currentranchshop}, function(checkmoney)
        if checkmoney[1] then
            cb(checkmoney[1])
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('rsg-ranch:server:ranchshopWithdraw')
AddEventHandler('rsg-ranch:server:ranchshopWithdraw', function(location, smoney)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local Playercid = Player.PlayerData.citizenid
    
    MySQL.query('SELECT * FROM ranch_shop WHERE shopid = ?',{location} , function(result)
        if result[1] ~= nil then
            if result[1].money >= tonumber(smoney) then
                local nmoney = result[1].money - smoney
                MySQL.update('UPDATE ranch_shop SET money = ? WHERE shopid = ?',{nmoney, location})
                Player.Functions.AddMoney('cash', smoney)
            else
                --Notif
            end
        end
    end)
end)

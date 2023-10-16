local RSGCore = exports['rsg-core']:GetCoreObject()
local collecting = false

-----------------------------------------------------------------------------------

-- target and collect poo
CreateThread(function()
    exports['rsg-target']:AddTargetModel(Config.FertilizerProps, {
        options = {
            {
                type = "client",
                event = 'rsg-ranch:client:collectpoo',
                icon = "far fa-eye",
                label = 'Pickup Poo',
                distance = 2.0
            }
        }
    })
end)

-----------------------------------------------------------------------------------

-- do collecting poo
RegisterNetEvent('rsg-ranch:client:collectpoo')
AddEventHandler('rsg-ranch:client:collectpoo', function()
    if collecting then return end

    local hasItem = RSGCore.Functions.HasItem('bucket', 1)
    local PlayerJob = RSGCore.Functions.GetPlayerData().job.name

    if (PlayerJob == 'macfarranch') or (PlayerJob == 'prongranch') then
    
        -- check has item
        if not hasItem then
            lib.notify({ title = 'Bucket Needed', description = 'you need a bucket to be able to do this!', type = 'error' })
            return
        end

        local ped = PlayerPedId()
        collecting = true
        LocalPlayer.state:set("inv_busy", true, true)
        local pooObject = nil
        local coords = nil

        FreezeEntityPosition(ped, true)

        for i = 1, #Config.FertilizerProps do
            local obj = Config.FertilizerProps[i]
            local pos = GetEntityCoords(PlayerPedId())
            local poo = GetClosestObjectOfType(pos, 2.5, obj, false, false, false)

            if poo and poo ~= 0 then
                pooObject = poo
                coords = GetEntityCoords(pooObject)

                if coords then break end
            end
        end

        if lib.progressCircle({
            duration = Config.CollectPooTime,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            anim = {
                dict = 'ai_gestures@gen_male@standing@speaker',
                clip = 'empathise_headshake_f_001',
                flag = 15
            },
        }) then 
        
            if coords then
                RSGCore.Functions.TriggerCallback('rsg-ranch:server:checkcollectedpoop', function(exists)
                    if not exists then
                        DeleteEntity(pooObject)
                        SetObjectAsNoLongerNeeded(pooObject)
                        TriggerServerEvent('rsg-ranch:server:collectedpoop', coords)
                        TriggerServerEvent('rsg-ranch:server:collectjobproduct', PlayerJob, 'fertilizer', 1)
                        lib.notify({ title = 'Fertilizer Collected', description = 'you successfully collected some fertilizer!', type = 'success' })
                    else
                        DeleteEntity(pooObject)
                        SetObjectAsNoLongerNeeded(pooObject)
                        lib.notify({ title = 'No Longer Available', description = 'already taken by you or someone else previously!', type = 'error' })
                    end
                end, coords)
            end
            collecting = false
            LocalPlayer.state:set("inv_busy", false, true)
            FreezeEntityPosition(ped, false)
        end
    else
        lib.notify({ title = 'Not Authorised', description = 'you don\'t have access to this!', type = 'error' })
    end
end)

---------------------------------------------------------------------------------

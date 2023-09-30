local RSGCore = exports['rsg-core']:GetCoreObject()

-------------------------------------------------------------------------------------------
-- prompts and blips
-------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    for _, v in pairs(Config.RanchLocations) do
        exports['rsg-core']:createPrompt(v.id, v.coords, RSGCore.Shared.Keybinds[Config.Keybind], 'Open '..v.name, {
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
        RSGCore.Functions.Notify('no access!', 'error')
    end
end)

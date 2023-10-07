Config = Config or {}
Config.RanchAnimals = {}

-- settings
Config.Keybind = 'J'
Config.MaxAnimalCount = 50
Config.HealthRemovePerCycle = 1
Config.ProductAddPerCycle = 1
Config.CheckCycle = 1 -- minutes it waits until it does an update
Config.AnimalFeedAdd = 10
Config.AnimalDieAge = 30
Config.AnimalTargetDistance = 5.0

-- authorised jobs
Config.AuthorisedJobs = {
    'macfarranch',
}

-- ranch blip settings
Config.RanchBlip = {
    blipName   = 'Ranch', -- Config.Blip.blipName
    blipSprite = 'blip_ambient_herd', -- Config.Blip.blipSprite
    blipScale  = 0.2 -- Config.Blip.blipScale
}

-- ranch shop blip settings
Config.RanchShopBlip = {
    blipName = 'Ranch Shop', -- Config.Blip.blipName
    blipSprite = 'blip_shop_store', -- Config.Blip.blipSprite
    blipScale = 0.2 -- Config.Blip.blipScale
}

Config.RanchLocations = {
    {
        name = 'Macfarlane Ranch',
        ranchid = 'macfarranch',
        coords = vector3(-2375.171, -2374.125, 62.37881),
        job = 'macfarranch',
        showblip   = true
    },
}

-- ranch shops
Config.RanchShops = {

    {
        shopid = 'macfarranchshop',
        shopname = 'Ranch Shop',
        coords = vector3(-2367.547, -2387.013, 62.176456),
        jobaccess = 'macfarranch',
        showblip = true
    },
    
}

-- npc coords
-- vector4(-2375.171, -2374.125, 62.37881, 194.37658) -- boss menu
-- vector4(-2367.547, -2387.013, 62.176456, 5.2386674) -- ranch shop
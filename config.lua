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
Config.CollectPooTime = 10000

-- animal cost
Config.CowPrice = 50
Config.SheepPrice = 25
Config.ChickenPrice = 1
Config.PigPrice = 1

-- animal wander distance
Config.CowWanderDistance = 4.0
Config.SheepWanderDistance = 3.0
Config.ChickenWanderDistance = 0.5
Config.PigWanderDistance = 2.0

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

-- ranch dealer blip settings
Config.RanchDealerBlip = {
    blipName = 'Ranch Dealer', -- Config.Blip.blipName
    blipSprite = 'blip_shop_store', -- Config.Blip.blipSprite
    blipScale = 0.2 -- Config.Blip.blipScale
}

Config.RanchLocations = {
    {    -- IMPORTANT : ranchid & job must be the same
        name = 'Macfarlane Ranch',
        ranchid = 'macfarranch',
        coords = vector3(-2375.171, -2374.125, 62.37881),
        job = 'macfarranch',
        showblip = true
    },
    {
        name = 'Pronghorn Ranch',
        ranchid = 'prongranch',
        coords = vector3(-2568.169, 353.48822, 151.47889),
        job = 'prongranch',
        showblip = true
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
    {
        shopid = 'prongranchshop',
        shopname = 'Ranch Shop',
        coords = vector3(-2560.69, 402.01995, 148.22892),
        jobaccess = 'prongranch',
        showblip = true
    },
    
}

-- ranch animal dealer
Config.RanchAnimalDealer = {

    {
        id = 'armranchdealer',
        name = 'Ranch Dealer',
        coords = vector3(-3676.736, -2556.874, -13.57845),
        animalspawn = vector3(-3670.964, -2557.247, -13.58261),
        jobaccess = 'macfarranch',
        showblip = true
    },
    {
        id = 'strranchdealer',
        name = 'Ranch Dealer',
        coords = vector3(-1772.601, -434.5156, 155.08004),
        animalspawn = vector3(-1776.907, -433.4537, 155.07099),
        jobaccess = 'prongranch',
        showblip = true
    },

}

Config.FertilizerProps = {
    `p_horsepoop02x`,
    `p_horsepoop03x`,
    `new_p_horsepoop02x_static`,
    `p_poop01x`,
    `p_poop02x`,
    `p_poopile01x`,
    `p_sheeppoop01`,
    `p_sheeppoop02x`,
    `p_sheeppoop03x`,
    `p_wolfpoop01x`,
    `p_wolfpoop02x`,
    `p_wolfpoop03x`,
    `s_horsepoop01x`,
    `s_horsepoop02x`,
    `s_horsepoop03x`,
    `mp007_p_mp_horsepoop03x`,
}

Config.RanchDealerShop = {
    -- shop items
    [1] = { name = 'chicken',    price = 5, amount = 50, info = {}, type = 'item', slot = 1, },
    [2] = { name = 'pig',        price = 5, amount = 50, info = {}, type = 'item', slot = 2, },
    [3] = { name = 'animalfeed', price = 1, amount = 50, info = {}, type = 'item', slot = 3, },
}

-- npc coords
-------------------------------------------------------------------------------
-- Macfarlane Ranch
-- vector4(-2375.171, -2374.125, 62.37881, 194.37658) -- boss menu
-- vector4(-2367.547, -2387.013, 62.176456, 5.2386674) -- ranch shop
-- vector4(-2376.891, -2383.489, 61.529312, 185.90876) -- wagon spawn
-------------------------------------------------------------------------------
-- Pronghorn Ranch
-- vector4(-2568.169, 353.48822, 151.47889, 358.87481)  -- boss menu
-- vector4(-2560.69, 402.01995, 148.22892, 95.87107) -- ranch shop
-- vector4(-2572.45, 362.97662, 150.49966, 86.822937) -- wagon spawn
-------------------------------------------------------------------------------
-- Ranch Dealers
-- vector4(-3676.736, -2556.874, -13.57845, 272.95428) -- ranch dealer amadillo
-- vector4(-1772.601, -434.5156, 155.08004, 111.57814) -- ranch dealre stawberry
-------------------------------------------------------------------------------
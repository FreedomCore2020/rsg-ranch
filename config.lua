Config = Config or {}
Config.RanchAnimals = {}

-- settings
Config.Keybind = 'J'
Config.MaxAnimalCount = 50
Config.HealthRemovePerCycle = 1
Config.ProductAddPerCycle = 1
Config.CheckCycle = 1 -- minutes it waits until it does an update
Config.AnimalFeedAdd = 10

-- authorised jobs
Config.AuthorisedJobs = {
    'macfarranch',
}

-- blacksmith blip settings
Config.RanchBlip = {
    blipName   = 'Ranch', -- Config.Blip.blipName
    blipSprite = 'blip_ambient_herd', -- Config.Blip.blipSprite
    blipScale  = 0.2 -- Config.Blip.blipScale
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

-- ranch shop
Config.RanchShop = {
    [1] = { name = "cow",        price = 50, amount = 10,  info = {}, type = "item", slot = 1, },
    [2] = { name = "sheep",      price = 25, amount = 10,  info = {}, type = "item", slot = 2, },
    [3] = { name = "animalfeed", price = 1,  amount = 500, info = {}, type = "item", slot = 3, },
}

-- npc coords
-- vector4(-2375.171, -2374.125, 62.37881, 194.37658)
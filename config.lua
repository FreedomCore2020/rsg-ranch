Config = Config or {}
Config.RanchAnimals = {}

-- settings
Config.Keybind = 'J'
Config.MaxAnimalCount = 50

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

-- npc coords
-- vector4(-2375.171, -2374.125, 62.37881, 194.37658)
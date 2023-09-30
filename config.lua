Config = {}

-- settings
Config.Keybind = 'J'

-- blacksmith blip settings
Config.RanchBlip = {
    blipName   = 'Ranch', -- Config.Blip.blipName
    blipSprite = 'blip_ambient_herd', -- Config.Blip.blipSprite
    blipScale  = 0.2 -- Config.Blip.blipScale
}

Config.RanchLocations = {
    {
        name = 'Macfarlane Ranch',
        id = 'macfarranch',
        coords = vector3(-2375.171, -2374.125, 62.37881),
		job = 'macfarrancher',
        showblip   = true
    },
}

-- npc coords
-- vector4(-2375.171, -2374.125, 62.37881, 194.37658)
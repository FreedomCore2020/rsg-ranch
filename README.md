# RexshackGaming
- discord : https://discord.gg/eW3ADkf4Af
- youtube : https://www.youtube.com/channel/UCikEgGfXO-HCPxV5rYHEVbA
- github : https://github.com/Rexshack-RedM

# Dependancies
- rsg-core
- ox_lib

# Installation
- ensure that the dependancies are added and started
- add the following table to your database : rsg-ranch.sql
- add items to your "\rsg-core\shared\items.lua"
- add images to your "\rsg-inventory\html\images"
- add rsg-ranch to your resources folder

# add to shared jobs
```lua
    ['macfarranch'] = {
        label = 'Macfarlane Rancher',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Ranch Trainee', payment = 25 },
            ['1'] = { name = 'Ranch Hand', payment = 30 },
            ['2'] = { name = 'Ranch Manager', payment = 35 },
            ['3'] = { name = 'Ranch Boss', isboss = true, payment = 40 },
        },
    },
```

# Starting the resource
- add the following to your server.cfg file : ensure rsg-ranch

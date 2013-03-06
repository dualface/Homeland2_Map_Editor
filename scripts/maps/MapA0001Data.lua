
------------ MAP A0001 ------------

local map = {}

map.size = {width = 1600, height = 1000}
map.imageName = "MapA0001Bg.webp"

local objects = {}

local object = {
    points = {
        { 260,  363}, { 351,  363}, { 479,  361}, { 616,  360}, { 745,  360}, { 917,  357},
        { 980,  357}, {1072,  357}, {1183,  359}, {1291,  357}, {1361,  359},
     }
}
objects["path:6"] = object

----

local object = {
    points = {
        { 792,  988}, { 793,  933}, { 794,  902}, { 795,  843}, { 796,  804}, { 791,  764},
        { 783,  744}, { 769,  732}, { 750,  723}, { 709,  709}, { 659,  697}, { 598,  682},
        { 538,  667}, { 498,  652}, { 469,  641}, { 446,  624}, { 435,  607}, { 429,  592},
        { 420,  530}, { 418,  494}, { 417,  451}, { 415,  390}, { 413,  343}, { 417,  300},
        { 425,  263}, { 437,  234}, { 455,  205}, { 486,  174}, { 513,  159}, { 554,  145},
        { 605,  134}, { 653,  126}, { 719,  120},
     }
}
objects["path:8"] = object

----

local object = {
    points = {
        { 800,  988}, { 801,  953}, { 801,  924}, { 801,  884}, { 801,  832}, { 801,  798},
        { 801,  782}, { 804,  769}, { 812,  749}, { 828,  732}, { 857,  720}, { 895,  708},
        { 955,  693}, {1012,  679}, {1067,  659}, {1112,  644}, {1166,  622}, {1179,  609},
        {1185,  596}, {1188,  578}, {1191,  530}, {1191,  478}, {1192,  403}, {1193,  369},
        {1189,  328}, {1184,  286}, {1179,  267}, {1167,  244}, {1158,  227}, {1144,  208},
        {1127,  188}, {1109,  168}, {1088,  154}, {1061,  141}, {1022,  130}, { 990,  126},
        { 904,  119},
     }
}
objects["path:9"] = object

----

local object = {
    radius = 153,
    tag = 0,
    x = 786,
    y = 380,
}
objects["range:11"] = object

----

local object = {
    behaviors = {
        "CampBehavior",
        "CollisionBehavior",
        "FireBehavior",
        "MovableBehavior",
    },
    bindingMovingForward = true,
    bindingPathId = "path:6",
    bindingPointIndex = 7,
    campId = 1,
    collisionEnabled = true,
    defineId = "Building01",
    flipSprite = false,
    initVisible = true,
    tag = 0,
    x = 980,
    y = 357,
}
objects["static:1"] = object

----

local object = {
    behaviors = {
        "CampBehavior",
        "CollisionBehavior",
        "DecorateBehavior",
        "DestroyedBehavior",
        "FireBehavior",
        "MovableBehavior",
        "NPCBehavior",
    },
    bindingMovingForward = false,
    bindingPathId = "path:6",
    bindingPointIndex = 5,
    campId = 2,
    collisionEnabled = true,
    decorationsMore = {
    },
    defineId = "EnemyShip03",
    flipSprite = true,
    initVisible = true,
    npcId = "NPC001",
    tag = 0,
    x = 745,
    y = 360,
}
objects["static:10"] = object

----

local object = {
    behaviors = {
        "BuildingBehavior",
        "CampBehavior",
        "CollisionBehavior",
        "DecorateBehavior",
        "DestroyedBehavior",
    },
    buildingId = "BuildingP001",
    campId = 1,
    collisionEnabled = true,
    decorationsMore = {
        "Building03BoardB01",
    },
    defineId = "Building03",
    flipSprite = false,
    initVisible = true,
    tag = 0,
    x = 805,
    y = 142,
}
objects["static:3"] = object

----

local object = {
    behaviors = {
        "CampBehavior",
        "CollisionBehavior",
        "DecorateBehavior",
        "DestroyedBehavior",
        "FireBehavior",
        "TowerBehavior",
    },
    campId = 1,
    collisionEnabled = true,
    decorationsMore = {
        "PlayerTower02Board01",
    },
    defineId = "PlayerTower02",
    flipSprite = false,
    initVisible = true,
    tag = 0,
    towerId = "Tower02L01",
    x = 693,
    y = 209,
}
objects["static:4"] = object

----

local object = {
    behaviors = {
        "CampBehavior",
        "CollisionBehavior",
        "DecorateBehavior",
        "DestroyedBehavior",
        "FireBehavior",
        "TowerBehavior",
    },
    campId = 1,
    collisionEnabled = true,
    decorationsMore = {
        "PlayerTower02Board01",
    },
    defineId = "PlayerTower02",
    flipSprite = false,
    initVisible = true,
    tag = 0,
    towerId = "Tower02L01",
    x = 928,
    y = 200,
}
objects["static:5"] = object

----

local object = {
    behaviors = {
        "CampBehavior",
        "CollisionBehavior",
        "DecorateBehavior",
        "DestroyedBehavior",
        "FireBehavior",
        "MovableBehavior",
        "PlayerBehavior",
    },
    bindingMovingForward = true,
    bindingPathId = "path:6",
    bindingPointIndex = 1,
    campId = 1,
    collisionEnabled = true,
    decorationsMore = {
    },
    defineId = "PlayerShip01",
    flipSprite = false,
    initVisible = true,
    playerTestId = "Player001",
    tag = 0,
    x = 260,
    y = 363,
}
objects["static:7"] = object

----

map.objects = objects

return map

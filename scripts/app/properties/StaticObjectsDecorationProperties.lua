
local StaticObjectsDecorationProperties = {}

local defines = {}

local decoration = {
    framesName      = "ShipWaveUpA%04d.png",
    framesBegin     = 1,            -- 从 ShipWaveUp0001.png 开始
    framesLength    = 16,           -- 一共有 16 帧
    framesTime      = 1.0 / 20,     -- 播放速度为每秒 20 帧

    -- 以下为都为可选设定
    zorder          = 1,            -- 在被装饰对象的 ZOrder 基础上 +1，默认值为 0
    playForever     = true,         -- 是否循环播放，默认值为 false
    autoplay        = true,         -- 是否自动开始播放，默认值为 false
    removeAfterPlay = false,        -- 播放一次后自动删除，仅当 playForever = false 时有效，默认值为 false
    hideAfterPlay   = false,        -- 播放一次后隐藏，仅当 playForever = false 时有效，默认值为 false
    visible         = true,         -- 是否默认可见，默认值为 true
    offsetX         = 0,            -- 图像的横向偏移量，默认值为 0
    offsetY         = -4,           -- 图像的纵向偏移量，默认值为 0
}
defines["ShipWavesUp"] = decoration

local decoration = {
    framesName   = "ShipWaveA%04d.png",
    framesBegin  = 1,
    framesLength = 16,
    framesTime   = 1.0 / 20,
    zorder       = -2,
    playForever  = true,
    autoplay     = true,
    offsetX      = 0,
    offsetY      = -4,
}
defines["ShipWaves"] = decoration

---------------------------------------- 风之使者

local decoration = {
    framesName   = "GodSkillWind%04d.png",
    framesBegin  = 1,
    framesLength = 10,
    framesTime   = 0.4 / 10,
    zorder       = 8,
    playForever  = true,
    offsetX      = 0,
    offsetY      = 30,
    scale        = 1.2,
    visible      = false,
}
defines["GodSkillWind"] = decoration

---------------------------------------- 灵魂枷锁

local decoration = {
    framesName   = "SoulChains%04d.png",
    framesBegin  = 1,
    framesLength = 11,
    framesTime   = 0.4 / 11,
    zorder       = 10,
    offsetX      = 6,
    offsetY      = -24,
}
defines["SoulChains"] = decoration

local decoration = {
    framesName   = "SoulChainsBack%04d.png",
    framesBegin  = 1,
    framesLength = 11,
    framesTime   = 0.4 / 11,
    zorder       = -10,
    offsetX      = 6,
    offsetY      = -24,
}
defines["SoulChainsBack"] = decoration

local decoration = {
    framesName   = "SoulChainsRestore%04d.png",
    framesBegin  = 1,
    framesLength = 5,
    framesTime   = 0.3 / 5,
    zorder       = 10,
    offsetX      = 4,
    offsetY      = -13,
}
defines["SoulChainsRestore"] = decoration

local decoration = {
    framesName   = "SoulChainsRestoreBack%04d.png",
    framesBegin  = 1,
    framesLength = 5,
    framesTime   = 0.3 / 5,
    zorder       = -10,
    offsetX      = 4,
    offsetY      = -1,
}
defines["SoulChainsRestoreBack"] = decoration

---------------------------------------- 冰环
-- 释放冰环出现的大冰环
local decoration = {
    framesName   = "IceRingExplode%04d.png",
    framesBegin  = 1,
    framesLength = 15,
    framesTime   = 0.55 / 15,
    offsetX      = 0,
    offsetY      = 0,
    scale        = 2,
}
defines["IceRingExplode"] = decoration

-- 冰冻时下面出现的烟雾
local decoration = {
    framesName   = "IceRingSmokeBack%04d.png",
    framesBegin  = 1,
    framesLength = 13,
    framesTime   = 0.65 / 13,
    zorder       = -5,
    scale        = 2,
    delay        = 0.2,
}
defines["IceRingSmokeBack"] = decoration

-- 冰冻时，目标身上出现的烟雾
local decoration = {
    framesName   = "IceRingSmoke%04d.png",
    framesBegin  = 1,
    framesLength = 12,
    framesTime   = 0.6 / 12,
    zorder       = 5001,
    scale        = 3,
    delay        = 0.2,
}
defines["IceRingSmoke"] = decoration

-- 冰冻层
local decoration = {
    imageName = "#IceRingFrozen.png",
    zorder    = 1,
    offsetY   = 20,
}
defines["IceRingFrozen"] = decoration

---------------------------------------- 回城

local decoration = {
    framesName      = "ReturnBasePillar%04d.png",
    framesBegin     = 1,
    framesLength    = 20,
    framesTime      = 1.0 / 20,
    zorder          = 2,
    offsetX         = -10,
    offsetY         = 102,
    scale           = 3,
    delay           = 0.6,
    removeAfterPlay = true,
}
defines["ReturnBasePillar"] = decoration

local decoration = {
    framesName      = "ReturnBaseCircle%04d.png",
    framesBegin     = 1,
    framesLength    = 22,
    framesTime      = 1.6 / 22,
    zorder          = -1,
    offsetX         = 4,
    offsetY         = -10,
    scale           = 2,
    removeAfterPlay = true,
}
defines["ReturnBaseCircle"] = decoration

local decoration = {
    framesName      = "ReturnBaseLights%04d.png",
    framesBegin     = 1,
    framesLength    = 16,
    framesTime      = 1.2 / 16,
    zorder          = 2,
    offsetX         = -6,
    offsetY         = 28,
    scale           = 2,
    delay           = 0.4,
    removeAfterPlay = true,
}
defines["ReturnBaseLights"] = decoration

local decoration = {
    framesName      = "ReturnBasePillar%04d.png",
    framesBegin     = 1,
    framesLength    = 20,
    framesReversed  = true,
    framesTime      = 1.0 / 20,
    zorder          = 2,
    offsetX         = -10,
    offsetY         = 102,
    scale           = 3,
    removeAfterPlay = true,
}
defines["ReturnBasePillarReversed"] = decoration

local decoration = {
    framesName      = "ReturnBaseCircle%04d.png",
    framesBegin     = 1,
    framesLength    = 22,
    framesReversed  = true,
    framesTime      = 1.6 / 22,
    zorder          = -1,
    offsetX         = 4,
    offsetY         = -10,
    scale           = 2,
    removeAfterPlay = true,
}
defines["ReturnBaseCircleReversed"] = decoration

local decoration = {
    framesName      = "ReturnBaseLights%04d.png",
    framesBegin     = 1,
    framesLength    = 16,
    framesReversed  = true,
    framesTime      = 1.2 / 16,
    zorder          = 2,
    offsetX         = -6,
    offsetY         = 28,
    scale           = 2,
    removeAfterPlay = true,
}
defines["ReturnBaseLightsReversed"] = decoration

---------------------------------------- 进入漩涡

local decoration = {
    framesName      = "EnterVortex%04d.png",
    framesBegin     = 1,
    framesLength    = 9,
    framesTime      = 0.4 / 9,
    zorder          = 3,
    offsetX         = 0,
    offsetY         = 30,
    scale           = 1.2,
    removeAfterPlay = true,
}
defines["EnterVortex"] = decoration

local decoration = {
    framesName      = "ExitVortex%04d.png",
    framesBegin     = 1,
    framesLength    = 9,
    framesTime      = 0.4 / 9,
    zorder          = 3,
    offsetX         = 0,
    offsetY         = 30,
    scale           = 1.2,
    removeAfterPlay = true,
}
defines["ExitVortex"] = decoration

---------------------------------------- 产生新船

local decoration = {
    framesName      = "NewShip%04d.png",
    framesBegin     = 1,
    framesLength    = 43,
    framesTime      = 2.2 / 43,
    zorder          = 10,
    offsetX         = 7,
    offsetY         = 56,
    scale           = 2.0,
    removeAfterPlay = true,
}
defines["NewShip"] = decoration

---------------------------------------- 舰船爆炸

local decoration = {
    framesName      = "ShipExplode%04d.png",
    framesBegin     = 1,
    framesLength    = 12,
    framesTime      = 0.6 / 12,
    offsetX         = 14,
    offsetY         = 24,
    scale           = 2,
    zorder          = 5,
    delay           = 0.4,
    removeAfterPlay = true,
}
defines["ShipExplode"] = decoration

local decoration = {
    framesName      = "ShipExplodeSmall01%04d.png",
    framesBegin     = 1,
    framesLength    = 8,
    framesTime      = 0.35 / 8,
    offsetX         = 0,
    offsetY         = 24,
    zorder          = 6,
    scale           = 2,
    removeAfterPlay = true,
}
defines["ShipExplodeSmall01"] = decoration

local decoration = {
    framesName      = "ShipExplodeSmall02%04d.png",
    framesBegin     = 1,
    framesLength    = 6,
    framesTime      = 0.25 / 6,
    offsetX         = -6,
    offsetY         = 30,
    zorder          = 6,
    scale           = 1,
    removeAfterPlay = true,
}
defines["ShipExplodeSmall02"] = decoration

---------------------------------------- 建筑物爆炸

local decoration = {
    framesName      = "BuildingExplode%04d.png",
    framesBegin     = 1,
    framesLength    = 22,
    framesTime      = 1.1 / 22,
    zorder          = 1,
    removeAfterPlay = true,
}
defines["TowerExplode"] = decoration

local decoration = {
    imageName = {"#PlayerTower0201Destroyed.png", "#PlayerTower0202Destroyed.png", "#PlayerTower0203Destroyed.png"},
    offsetX   = {-24, -24, -24},
    offsetY   = {10, 13, 12},
    visible   = false,
}
defines["PlayerTower02Destroyed"] = decoration

local decoration = {
    framesName   = "PlayerTower02Fire%04d.png",
    framesBegin  = 1,
    framesLength = 8,
    framesTime   = 0.48 / 8,
    zorder       = 1,
    offsetY      = 36,
}
defines["PlayerTower02Fire"] = decoration

local decoration = {
    framesName   = "Tower02Fire2%04d.png",
    framesBegin  = 1,
    framesLength = 20,
    framesTime   = 1.2 / 20,
    zorder       = 2,
    offsetX      = 2,
    offsetY      = 68,
    visible      = false,
}
defines["Tower02Fire2"] = decoration

local decoration = {
    imageName = {"#PlayerTower0301Destroyed.png", "#PlayerTower0302Destroyed.png", "#PlayerTower0303Destroyed.png"},
    offsetX   = {-15, -15, -15},
    offsetY   = {15, 15, 15},
    visible   = false,
}
defines["PlayerTower03Destroyed"] = decoration

--------------------------------------- 友军塔底板

local decoration = {
    imageName = "#PlayerTower01Board01.png",
    offsetX   = -4,
    offsetY   = -4,
    zorder    = -1,
}
defines["PlayerTower01Board01"] = decoration

local decoration = {
    imageName = "#PlayerTower01Board02.png",
    offsetX   = -5,
    offsetY   = -3,
    zorder    = -1,
}
defines["PlayerTower01Board02"] = decoration

local decoration = {
    imageName = "#PlayerTower01Board03.png",
    offsetX   = -5,
    offsetY   = -3,
    zorder    = -1,
}
defines["PlayerTower01Board03"] = decoration

local decoration = {
    imageName = "#PlayerTower01Board04.png",
    offsetX   = -5,
    offsetY   = -3,
    zorder    = -1,
}
defines["PlayerTower01Board04"] = decoration


local decoration = {
    imageName = "#PlayerTower01Board05.png",
    offsetX   = -5,
    offsetY   = -3,
    zorder    = -1,
}
defines["PlayerTower01Board05"] = decoration

local decoration = {
    imageName = "#PlayerTower02Board01.png",
    offsetX   = -6,
    offsetY   = 2,
    zorder    = -1,
}
defines["PlayerTower02Board01"] = decoration

local decoration = {
    imageName = "#PlayerTower02Board02.png",
    offsetX   = -6,
    offsetY   = 2,
    zorder    = -1,
}
defines["PlayerTower02Board02"] = decoration

local decoration = {
    imageName = "#PlayerTower02Board03.png",
    offsetX   = -6,
    offsetY   = 2,
    zorder    = -1,
}
defines["PlayerTower02Board03"] = decoration

local decoration = {
    imageName = "#PlayerTower02Board04.png",
    offsetX   = -6,
    offsetY   = 2,
    zorder    = -1,
}
defines["PlayerTower02Board04"] = decoration

local decoration = {
    imageName = "#PlayerTower02Board05.png",
    offsetX   = -5,
    offsetY   = -1,
    zorder    = -1,
}
defines["PlayerTower02Board05"] = decoration

local decoration = {
    imageName = "#PlayerTower03Board01.png",
    offsetX   = -6,
    offsetY   = 0,
    zorder    = -1,
}
defines["PlayerTower03Board01"] = decoration

local decoration = {
    imageName = "#PlayerTower03Board02.png",
    offsetX   = -6,
    offsetY   = 0,
    zorder    = -1,
}
defines["PlayerTower03Board02"] = decoration

local decoration = {
    imageName = "#PlayerTower03Board03.png",
    offsetX   = -6,
    offsetY   = 0,
    zorder    = -1,
}
defines["PlayerTower03Board03"] = decoration

local decoration = {
    imageName = "#PlayerTower03Board04.png",
    offsetX   = -6,
    offsetY   = 0,
    zorder    = -1,
}
defines["PlayerTower03Board04"] = decoration

local decoration = {
    imageName = "#PlayerTower03Board05.png",
    offsetX   = -6,
    offsetY   = 0,
    zorder    = -1,
}
defines["PlayerTower03Board05"] = decoration

--------------------------------------- 友军塔底板


local decoration = {
    imageName = {"#PlayerTower0101Destroyed.png", "#PlayerTower0102Destroyed.png", "#PlayerTower0103Destroyed.png"},
    offsetX   = {-13, -14, -14},
    offsetY   = {5, 5, 5},
    visible   = false,
}
defines["PlayerTower01Destroyed"] = decoration

--------------------------------------- 敌军塔底板

local decoration = {
    imageName = "#EnemyTower01Board01.png",
    offsetX   = -5,
    offsetY   = -3,
    zorder    = -1,
}
defines["EnemyTower01Board01"] = decoration

local decoration = {
    imageName = "#EnemyTower01Board02.png",
    offsetX   = -5,
    offsetY   = -3,
    zorder    = -1,
}
defines["EnemyTower01Board02"] = decoration

local decoration = {
    imageName = "#EnemyTower01Board03.png",
    offsetX   = -5,
    offsetY   = -3,
    zorder    = -1,
}
defines["EnemyTower01Board03"] = decoration

local decoration = {
    imageName = "#EnemyTower01Board04.png",
    offsetX   = -5,
    offsetY   = -3,
    zorder    = -1,
}
defines["EnemyTower01Board04"] = decoration

local decoration = {
    imageName = "#EnemyTower02Board01.png",
    offsetX   = -4,
    offsetY   = -2,
    zorder    = -1,
}
defines["EnemyTower02Board01"] = decoration

local decoration = {
    imageName = "#EnemyTower02Board02.png",
    offsetX   = -4,
    offsetY   = -2,
    zorder    = -1,
}
defines["EnemyTower02Board02"] = decoration

local decoration = {
    imageName = "#EnemyTower02Board03.png",
    offsetX   = -4,
    offsetY   = -2,
    zorder    = -1,
}
defines["EnemyTower02Board03"] = decoration

local decoration = {
    imageName = "#EnemyTower02Board04.png",
    offsetX   = -4,
    offsetY   = -2,
    zorder    = -1,
}
defines["EnemyTower02Board04"] = decoration

local decoration = {
    imageName = "#EnemyTower03Board01.png",
    offsetX   = -6,
    offsetY   = 0,
    zorder    = -1,
}
defines["EnemyTower03Board01"] = decoration

local decoration = {
    imageName = "#EnemyTower03Board02.png",
    offsetX   = -6,
    offsetY   = 0,
    zorder    = -1,
}
defines["EnemyTower03Board02"] = decoration


local decoration = {
    imageName = "#EnemyTower03Board03.png",
    offsetX   = -6,
    offsetY   = 0,
    zorder    = -1,
}
defines["EnemyTower03Board03"] = decoration

local decoration = {
    imageName = "#EnemyTower03Board04.png",
    offsetX   = -6,
    offsetY   = 0,
    zorder    = -1,
}
defines["EnemyTower03Board04"] = decoration

--------------------------------------- 敌军塔底板

local decoration = {
    imageName = {"#EnemyTower0101Destroyed.png", "#EnemyTower0102Destroyed.png", "#EnemyTower0103Destroyed.png"},
    offsetX   = {-13, -14, -14},
    offsetY   = {5, 5, 5},
    visible   = false,
}
defines["EnemyTower01Destroyed"] = decoration

local decoration = {
    imageName = {"#EnemyTower0201Destroyed.png", "#EnemyTower0202Destroyed.png", "#EnemyTower0203Destroyed.png"},
    offsetX   = {-20, -20, -20},
    offsetY   = {7, 9, 8},
    visible   = false,
}
defines["EnemyTower02Destroyed"] = decoration

local decoration = {
    framesName   = "EnemyTower02Fire%04d.png",
    framesBegin  = 1,
    framesLength = 8,
    framesTime   = 0.48 / 8,
    zorder       = 1,
    offsetY      = 30,
}
defines["EnemyTower02Fire"] = decoration

local decoration = {
    imageName = {"#EnemyTower0301Destroyed.png", "#EnemyTower0302Destroyed.png", "#EnemyTower0303Destroyed.png"},
    offsetX   = {-15, -15, -15},
    offsetY   = {15, 15, 15},
    visible   = false,
}
defines["EnemyTower03Destroyed"] = decoration

---------------------------------------- 掠夺攻击效果

local decoration = {
    framesName      = "PlunderHit%04d.png",
    framesBegin     = 1,
    framesLength    = 22,
    framesTime      = 1.1 / 22,
    offsetX         = 0,
    offsetY         = 80,
    zorder          = 6,
    scale           = 2,
    -- removeAfterPlay = true,
    visible         = false,
}
defines["PlunderHit"] = decoration

---------------------------------------- 反击效果
local decoration = {
    framesName      = "Counterattack%04d.png",
    framesBegin     = 1,
    framesLength    = 9,
    framesTime      = 0.45 / 9,
    offsetX         = 0,
    offsetY         = 50,
    zorder          = 6,
    scale           = 2,
    -- removeAfterPlay = true,
    visible         = false,
}
defines["CounterAttack"] = decoration

--------------------------------------------

local decoration = {
    framesName      = "BuildingExplode%04d.png",
    framesBegin     = 1,
    framesLength    = 22,
    framesTime      = 1.3 / 22,
    zorder          = 1,
    scale           = 1.8,
    offsetY         = 30,
    removeAfterPlay = true,
}
defines["BuildingExplode"] = decoration

local decoration = {
    imageName = "#Building01Destroyed.png",
    visible   = false,
    offsetX   = -10,
    offsetY   = 35,
}
defines["Building01Destroyed"] = decoration

local decoration = {
    imageName = "#Building03Destroyed.png",
    visible   = false,
    offsetX   = -13,
    offsetY   = 10,
}
defines["Building03Destroyed"] = decoration

----------------------------------- 敌军建筑物底板

local decoration = {
    imageName = "#Building01BoardA01.png",
    offsetX   = -10,
    offsetY   = 30,
    zorder    = -1,
}
defines["Building01BoardA01"] = decoration

local decoration = {
    imageName = "#Building01BoardA02.png",
    offsetX   = -10,
    offsetY   = 30,
    zorder    = -1,
}
defines["Building01BoardA02"] = decoration

local decoration = {
    imageName = "#Building01BoardA03.png",
    offsetX   = -10,
    offsetY   = 30,
    zorder    = -1,
}
defines["Building01BoardA03"] = decoration

local decoration = {
    imageName = "#Building01BoardA04.png",
    offsetX   = -10,
    offsetY   = 30,
    zorder    = -1,
}
defines["Building01BoardA04"] = decoration

local decoration = {
    imageName = "#Building01BoardB01.png",
    offsetX   = -5,
    offsetY   = -3,
    zorder    = -1,
}
defines["Building01BoardB01"] = decoration

----------------------------------- 友军建筑物底板

local decoration = {
    imageName = "#Building03BoardA01.png",
    offsetX   = -11,
    offsetY   = 8,
    zorder    = -1,
}
defines["Building03BoardA01"] = decoration

local decoration = {
    imageName = "#Building03BoardA02.png",
    offsetX   = -11,
    offsetY   = 8,
    zorder    = -1,
}
defines["Building03BoardA02"] = decoration

local decoration = {
    imageName = "#Building03BoardA03.png",
    offsetX   = -11,
    offsetY   = 8,
    zorder    = -1,
}
defines["Building03BoardA03"] = decoration

local decoration = {
    imageName = "#Building03BoardA04.png",
    offsetX   = -11,
    offsetY   = 8,
    zorder    = -1,
}
defines["Building03BoardA04"] = decoration

local decoration = {
    imageName = "#Building03BoardA05.png",
    offsetX   = -10,
    offsetY   = 5,
    zorder    = -1,
}
defines["Building03BoardA05"] = decoration

local decoration = {
    imageName = "#Building03BoardB01.png",
    offsetX   = -15,
    offsetY   = 7,
    zorder    = -1,
}
defines["Building03BoardB01"] = decoration


function StaticObjectsDecorationProperties.get(decorationName)
    return clone(defines[decorationName])
end

return StaticObjectsDecorationProperties

local MapEvent        = require("app.map.MapEvent")
local MapEventHandler = require("app.map.MapEventHandler")
local GodSkillType    = require("app.map.GodSkillType")

local MyMapEventHandler = class("MyMapEventHandler", MapEventHandler)

function MyMapEventHandler:preparePlay()
    -- 如果地方目标还未被摧毁，则每隔一定时间制造一个新的 NPC
    MyMapEventHandler.super:preparePlay(self)
    self.createEnemyEnabled_  = true
    self.createEnemyInterval_ = math.random(15, 20)
    self.createEnemyDelay_    = 0
    self.runtime_:dispatchEvent({
        name   = MapEvent.UI_CREATE_PROMPTTARGET,
        image  = "#BattleHelp02.png",
        x      = display.c_left + 273,
        y      = display.c_bottom + 153
    })
end

function MapEventHandler:startPlay()
    MyMapEventHandler.super:startPlay(self)
    local ship = self.map_:getObject("static:10")
    ship:startMoving()
end

function MyMapEventHandler:getCustomState()
    local state = MyMapEventHandler.super:getCustomState(self)
    state.createEnemyDelay    = self.createEnemyDelay_
    state.createEnemyInterval = self.createEnemyInterval_
    return state
end

function MyMapEventHandler:setCustomState(state)
    MyMapEventHandler.super:setCustomState(self, state)
    self.createEnemyDelay_ = state.createEnemyDelay
    self.createEnemyInterval_  = state.createEnemyInterval
end

-- 对象进入区域
function MyMapEventHandler:objectEnterRange(object, range)
    MyMapEventHandler.super.objectEnterRange(self, object, range)
    if object:isPlayer()then
        local rangeId = range:getId()
        if rangeId == "range:11" then
            self.runtime_:dispatchEvent({
                name   = MapEvent.UI_CREATE_PROMPTTARGET,
                image  = "#BattleHelp01.png",
                x      = display.c_left + 273,
                y      = display.c_bottom + 153
            })
        end
    end
end

function MyMapEventHandler:objectExitRange(object, range)
    MyMapEventHandler.super.objectExitRange(self, object, range)
    local rangeId = range:getId()
    if object:isPlayer() then
        if rangeId == "range:11" then
            self.runtime_:dispatchEvent({
                name   = MapEvent.UI_REMOVE_PROMPTTARGET,
            })
        end
    end
end

-- 每秒执行一次 time() 方法
function MyMapEventHandler:time(time, dt)
    MyMapEventHandler.super.time(self, time, dt)

    if self.createEnemyEnabled_ then
        self.createEnemyDelay_ = self.createEnemyDelay_ - dt
        if self.createEnemyDelay_ <= 0 then
            self.createEnemyDelay_ = self.createEnemyInterval_
            local state = {
                behaviors            = {"NPCBehavior"},
                bindingPathId        = "path:8",
                bindingPointIndex    = 2,
                bindingMovingForward = true,
                npcId                = "NPC001",
                campId               = 2,
                collisionEnabled     = true,
                defineId             = "EnemyShip03",
                flipSprite           = false,
            }

            local randomPath = math.random(1, 2)
            if randomPath == 2 then
                state.bindingPathId = "path:9"
            end

            self.runtime_:newShip(state, "startMoving")
            self.createEnemyInterval_ = math.random(15, 20)
        end
    end
end

function MyMapEventHandler:enemyBuildingDestroyed(object)
    MyMapEventHandler.super.enemyBuildingDestroyed(self, object)

    if object:getId() == "static:1" then
        self.runtime_:winGame()
    end
end

function MyMapEventHandler:playerBuildingDestroyed(object)
    MyMapEventHandler.super.playerBuildingDestroyed(self, object)

    if object:getId() == "static:3" then
        self.runtime_:loseGame()
    end
end

function MyMapEventHandler:useGodSkill(skillType)
     MyMapEventHandler.super.useGodSkill(self, skillType)

    if skillType == GodSkillType.GS01 then
        local player = self.runtime_:getPlayer()
        player:setMovingForward(true)
        self.runtime_:returnHomePlayerShip(player, "path:6", 1)
    end
end

return MyMapEventHandler

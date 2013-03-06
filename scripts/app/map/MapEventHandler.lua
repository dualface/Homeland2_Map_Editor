
local MapConstants    = require("app.map.MapConstants")
local MapEvent        = require("app.map.MapEvent")
local GodSkillType    = require("app.map.GodSkillType")
local ArmorType       = require("app.map.ArmorType")
local MovableBehavior = require("app.map.behaviors.MovableBehavior")
local BulletBase      = require("app.map.bullets.BulletBase")

local MapEventHandler = class("MapEventHandler")

function MapEventHandler:ctor(runtime, map)
    self.runtime_        = runtime
    self.map_            = map
    self.objectsInRange_ = {}
    self.increaseHpRate_ = 1 -- 玩家进入区域的加血百分比
    self.hitTime_        = 0 -- 击中目标激活技能时间
    self.getHitTime_     = 0 -- 被击中目标时间
end

-- 准备开始游戏
function MapEventHandler:preparePlay()
end

-- 开始游戏
function MapEventHandler:startPlay(state)
    local player = self.runtime_:getPlayer()
    if player.genius_["B12"] then
        self.increaseHpRate_ = self.increaseHpRate_ + player.genius_["B12"] / 100
    end

    if not state then return end

    player:setHp(state.player.hp)
    player:setMagic(state.player.magic)
    player:stopMovingNow()

    local batch = self.map_:getBatchLayer()
    local delay = MapConstants.RESUME_FROM_PK_DELAY

    if not player:isDestroyed() then
        local npc = self.map_:getObject(state.pk.npcId)
        npc:setHp(0)
        npc:updateView()
        npc:stopMovingNow()

        batch:performWithDelay(function()
            npc:showDestroyedStatus()
            npc:updateView()
            self:objectDestroyed(npc)
        end, delay)
    else
        player:updateView()
        batch:performWithDelay(function()
            player:showDestroyedStatus()
            player:updateView()
            self:objectDestroyed(player)
        end, delay)
    end
end

-- 停止游戏
function MapEventHandler:stopPlay()
end

--[[--

返回自定义的状态

]]
function MapEventHandler:getCustomState()
    local state = {
        hitTime = self.hitTime_,
        getHitTime = self.getHitTime_,
    }
    return state
end

--[[--

设置自定义的状态

]]
function MapEventHandler:setCustomState(state)
    self.hitTime_ = state.hitTime
    self.getHitTime_ = state.getHitTime
end

function MapEventHandler:prepareUseGodSkill(skillType)
end

function MapEventHandler:useGodSkill(skillType)
end

function MapEventHandler:endGodSkill(skill)
end

-- 每秒执行一次 time() 方法
function MapEventHandler:time(time, dt)
    for range, objects in pairs(self.objectsInRange_) do
        for object, times in pairs(objects) do
            local holdTime = time - times[1]
            local holdTimeDt = holdTime - times[2]
            times[2] = holdTime
            self:objectInRange(object, range, holdTime, holdTimeDt)
            self.runtime_:dispatchEvent({
                name       = MapEvent.OBJECT_IN_RANGE,
                object     = object,
                range      = range,
                holdTime   = holdTime,
                holdTimeDt = holdTimeDt,
            })
        end
    end
end

-- 对象进入区域
function MapEventHandler:objectEnterRange(object, range)
    if not self.objectsInRange_[range] then
        self.objectsInRange_[range] = {}
    end
    self.objectsInRange_[range][object] = {self.runtime_.time_, 0}
end

-- 对象退出区域
function MapEventHandler:objectExitRange(object, range)
    if self.objectsInRange_[range] then
        self.objectsInRange_[range][object] = nil
    end
end

-- 对象保持在区域中
-- holdTime 是对象在区域中的持续时间
-- holdTimeDt 是距离上一次 objcetInRange 事件后，对象在区域中的时间
function MapEventHandler:objectInRange(object, range, holdTime, holdTimeDt)
end

-- 对象发生碰撞
function MapEventHandler:objectCollisionBegan(object1, object2)
    -- if object1.collisionLock_ > 0 or object2.collisionLock_ > 0 then return end
    -- if object1:isPlayer()
    --         and object2:hasBehavior("NPCBehavior")
    --         and object2:getCampId() == MapConstants.ENEMY_CAMP then
    --     self.runtime_:dispatchEvent({
    --         name   = MapEvent.MAP_GOTO_PK,
    --         player = object1,
    --         npc    = object2,
    --     })
    -- end
end

-- 对象结束碰撞
function MapEventHandler:objectCollisionEnded(object1, object2)
    -- if DEBUG > 0 then
    --     echoLog("MAP", "collision ended: %s, %s", object1:getId(), object2:getId())
    -- end
end

-- 对目标开火
function MapEventHandler:fire(object, target)
    -- if DEBUG > 0 then
    --     echoLog("MAP", "object %s fire target %s", object:getId(), target:getId())
    -- end
    if string.sub(self.map_:getId(), 1, 1) == "H" then return end
    if object.fireLock_ > 0 or not object.fireEnabled_ then return end

    local bullets = object:fire(target)
    for i, bullet in ipairs(bullets) do
        self.map_:getBatchLayer():addChild(bullet:getView(), MapConstants.BULLET_ZORDER)
        self.runtime_:addBullet(bullet)
    end

    -- if not object:isPlayer() and not target:isPlayer() and object:hasBehavior("MovableBehavior") then
    --     -- 如果对象不是玩家，并且目标也不是玩家，同时对象是可以移动的，则停止对象移动
    --     object:stopMoving()
    -- end

    if not object:isPlayer() and object:hasBehavior("MovableBehavior") then
        -- 如果对象不是玩家，同时对象是可以移动的，则停止对象移动
        object:stopMoving()
    end

    -- 攻击目标时，发起攻击的对象会被保存到目标的 fireSources_ 数组中
    -- 在目标被摧毁时，发起攻击的对象会自动开始移动
    if not target.fireSources_ then
        target.fireSources_ = {}
        local mt = {__mode = "k"}   -- 弱引用表，当对象被删除时会自动从这个数组中删除
        setmetatable(target.fireSources_, mt)
    end
    target.fireSources_[object] = self.runtime_:getTime()
end

-- 对象的开火范围内没有目标
function MapEventHandler:noTarget(object)
    if not object:isPlayer() and object:hasBehavior("MovableBehavior") and not object:isMoving() then
        -- 如果对象不是玩家，同时对象是可以移动的，并且对象处于停止状态，则开始移动
        object:startMoving()
    end
end

-- 击中目标
function MapEventHandler:hit(object, target, bullet, time)
    if target:isDestroyed() or self.runtime_.over_ then return end
    -- 有敌舰攻击我方基地时出现警戒提示
    if target:getCampId() == 1 and string.sub(target:getDefineId(), 1, -3) == "Building" then
        if time - self.getHitTime_ >= 3 or self.getHitTime_ <= 0 then
            audio.playEffect(GAME_SFX.MAP_FIRED_CALL)
            self.runtime_:dispatchEvent({
                name = MapEvent.HIT_MY_BUIDING
            })
            self.getHitTime_ = time
        end
    end

    local damage = bullet.damage_
    -- 玩家火炮攻击不同炮塔的造成伤害处理
    if object:isPlayer() and not target:isPlayer() and target.armorType_ then
        if target.armorType_ == ArmorType.Light then
            damage = damage * object.lightArmorDamage_ / 100
        elseif target.armorType_ == ArmorType.Heavy then
            damage = damage * object.heavyArmorDamage_ / 100
        elseif target.armorType_ == ArmorType.MagicShield then
            damage = damage * object.magicShieldDamage_ / 100
        end
    end

    damage = damage * bullet.damageScale_ - target.maxArmor_ * bullet.damageScale_
    if damage <= 0 then
        damage = 1
    end

    if bullet.flag_ == BulletBase.FLAG_NORMAL
            and bullet.critical_
            and bullet.source_.criticalPower_ > 0 then
        damage = damage * bullet.source_.criticalPower_
        self:newHitLabel(bullet, "#HitCrit.png", damage)
    end
    local target = bullet.target_

    target:decreaseHp(damage)
    if bullet.flag_ == BulletBase.FLAG_NORMAL then
        if object:isPlayer() then
            if time - self.hitTime_ >= 2 or self.hitTime_ <= 0 then
                self:playerHitNpc(object, target)
                self.hitTime_ = time
            end
        elseif target:isPlayer() then
            self.runtime_:newLabelText(target, toint(damage), "decreaseHp")
            self:npcHitPlayer(target, object)
        else
            self:npcHitNpc(object, target)
        end
    end

    if target:isDestroyed() then
        if target:hasBehavior("MovableBehavior") then
            target:stopMoving()
        end
        target:showDestroyedStatus()
        target:updateView()
        self:objectDestroyed(target)
    end
end

-- 没有命中目标
function MapEventHandler:miss(object, target, bullet)
    self:newHitLabel(bullet, "#HitMiss.png")
end

-- 对象被摧毁
function MapEventHandler:objectDestroyed(object)
    self.runtime_:dispatchEvent({name = MapEvent.OBJECT_DESTROY, object = object})

    -- 当目标被摧毁时，攻击这个目标的所有对象如果是可以移动的，则这些对象会开始移动
    if object.fireSources_ then
        for obj, time in pairs(object.fireSources_) do
            if obj:hasBehavior("MovableBehavior") and not obj:isPlayer() then
                obj:startMoving()
            end
        end
        object.fireSources_ = nil
    end

    -- 当目标被摧毁时，目标身上的上帝技能都需要取消
    if object.godSkillsBinding_ then
        for skillType, skill in pairs(object.godSkillsBinding_) do
            if not skill.removed_ then skill:setOver(object) end
        end
        object.godSkillsBinding_ = nil
    end

    if object:hasBehavior("NPCBehavior") then
        -- NPC 舰船被摧毁
        self:npcDestroyed(object)
    elseif object:hasBehavior("TowerBehavior") then
        if object:getCampId() == MapConstants.PLAYER_CAMP then
            self:playerTowerDestroyed(object)
        else
            self:enemyTowerDestroyed(object)
        end
    elseif object:hasBehavior("BuildingBehavior") then
        if object:getCampId() == MapConstants.PLAYER_CAMP then
            self:playerBuildingDestroyed(object)
        else
            self:enemyBuildingDestroyed(object)
        end
    elseif object:isPlayer() then
        self:playerDead(object)
    end
end

function MapEventHandler:showShipExplode(object)
    local runtime = self.runtime_
    local radius = object.radius_ * 100
    object:addCollisionLock()

    for i = 1, 12 do
        local decoration = runtime:newDecoration(format("ShipExplodeSmall%02d", math.random(1, 2)), object)
        decoration:setDelay(math.random(2, 5) / 100 * (i - 1))
        decoration:setVisible(true)
        decoration:playAnimationOnceAndRemove()
        local ox = math.random(-radius, radius) / 100
        local oy = math.random(-radius, radius) / 100 * 0.8
        local view = decoration:getView()
        local x, y = view:getPosition()
        view:setPosition(x + ox, y + oy)
    end

    local decoration = runtime:newDecoration("ShipExplode", object)
    decoration:setDelay(decoration.delay_)
    decoration:playAnimationOnceAndRemove()
end

-- NPC 被摧毁
function MapEventHandler:npcDestroyed(object)
    if DEBUG > 0 then
        echoLog("MAP", "npc %s destroyed", object:getId())
    end
    audio.playEffect(GAME_SFX.MAP_SHIP_DESTROYED)
    self:showShipExplode(object)
end

-- 地方塔被摧毁
function MapEventHandler:enemyTowerDestroyed(object)
    if DEBUG > 0 then
        echoLog("MAP", "enemy tower %s destroyed", object:getId())
    end
    audio.playEffect(GAME_SFX.MAP_CANNON_DESTROYED)
    local decoration = self.runtime_:newDecoration("TowerExplode", object)
    decoration:playAnimationOnceAndRemove()
end

-- 玩家的塔被摧毁
function MapEventHandler:playerTowerDestroyed(object)
    if DEBUG > 0 then
        echoLog("MAP", "player tower %s destroyed", object:getId())
    end
    audio.playEffect(GAME_SFX.MAP_CANNON_DESTROYED)
    local decoration = self.runtime_:newDecoration("TowerExplode", object)
    decoration:playAnimationOnceAndRemove()
end

-- 敌方建筑物被摧毁
function MapEventHandler:enemyBuildingDestroyed(object)
    if DEBUG > 0 then
        echoLog("MAP", "enemy building %s destroyed", object:getId())
    end
    audio.playEffect(GAME_SFX.MAP_BUILD_DESTROYED)
    local decoration = self.runtime_:newDecoration("BuildingExplode", object)
    decoration:playAnimationOnceAndRemove()
end

-- 玩家建筑物被摧毁
function MapEventHandler:playerBuildingDestroyed(object)
    if DEBUG > 0 then
        echoLog("MAP", "player building %s destroyed", object:getId())
    end
    audio.playEffect(GAME_SFX.MAP_BUILD_DESTROYED)
    local decoration = self.runtime_:newDecoration("BuildingExplode", object)
    decoration:playAnimationOnceAndRemove()
end

-- 玩家死亡
function MapEventHandler:playerDead(player)
    self:showShipExplode(player)
    self.runtime_:loseGame(player)
end

----

function MapEventHandler:newHitLabel(bullet, imageName)
    local bulletView = bullet:getView()
    local hitLabel = display.newSprite(imageName)
    local x, y = bulletView:getPosition()
    hitLabel:setRotation(math.random(-15, 15))
    hitLabel:setPosition(x, y + 10)
    self.map_:getBatchLayer():addChild(hitLabel, MapConstants.BULLET_ZORDER + 1)

    hitLabel:setScale(0.01)
    transition.moveBy(hitLabel, {y = 20, time = 0.8})
    transition.scaleTo(hitLabel, {scale = 1.0, time = 0.4, easing = "ELASTICOUT"})
    transition.fadeOut(hitLabel, {delay = 0.4, time = 0.3, onComplete = function()
        if not tolua.isnull(hitLabel) then
            hitLabel:removeSelf()
        end
    end})
end

function MapEventHandler:npcHitNpc(object, target)
end

function MapEventHandler:playerHitNpc(player, npc)
    if not player.genius_ then return end
    local batch = self.map_:getBatchLayer()
    -- 掠夺和强化掠夺
    if player.genius_["B11"] then
        local ratio = math.random(1, 100)
        if ratio <= 20 then
            audio.playEffect(GAME_SFX.MAP_PLUNDER)
            local decoration = player:getDecoration("PlunderHit")
            decoration:setVisible(true)
            decoration:playAnimationForever()
            batch:performWithDelay(function()
                decoration:setVisible(false)
                decoration:stopAnimation()
            end, 1.1)


            local hp = player.genius_["B11"]
            player:increaseHp(hp)
            self.runtime_:dispatchEvent({
                name   = MapEvent.PLAYER_HP_CHANGED,
                player = player,
            })
        end
    end
end

function MapEventHandler:npcHitPlayer(player, npc)
    if not player.genius_ then return end
    local batch = self.map_:getBatchLayer()
    if player.genius_["B20"] then
        local ratio = math.random(1, 100)
        if ratio <= player.genius_["B20"] then
            audio.playEffect(GAME_SFX.MAP_COUNTER_ATTACK)
            local decoration = player:getDecoration("CounterAttack")
            decoration:setVisible(true)
            decoration:playAnimationForever()
            -- local decoration = self.runtime_:newDecoration("CounterAttack", player)
            batch:performWithDelay(function()
                decoration:setVisible(false)
                decoration:stopAnimation()
            end, 0.45)
            player.fireCooldown_ = 0
        end
    end

    self.runtime_:dispatchEvent({
        name   = MapEvent.PLAYER_HP_CHANGED,
        player = player,
    })
end

return MapEventHandler

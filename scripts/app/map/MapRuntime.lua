
local MapEvent     = require("app.map.MapEvent")
local MapConstants = require("app.map.MapConstants")
local Decoration   = require("app.map.Decoration")
local math2d       = require("math2d")

local MapRuntime = class("MapRuntime")

local kMapEventCollisionBegan    = 1
local kMapEventCollisionEnded    = 2
local kMapEventCollisionFire     = 3
local kMapEventCollisionNoTarget = 4

-- copy global to local
local kMapObjectClassIndexPath       = kMapObjectClassIndexPath
local kMapObjectClassIndexRange      = kMapObjectClassIndexRange
local kMapObjectClassIndexStatic     = kMapObjectClassIndexStatic

function MapRuntime:ctor(map, runtimeC)
    self.debug_                = map:isDebug()
    self.map_                  = map
    self.batch_                = map:getBatchLayer()
    self.camera_               = map:getCamera()
    self.starting_             = false
    self.over_                 = false
    self.paused_               = false
    self.player_               = nil -- 玩家对象
    self.promptTarget_         = nil -- 战场提示
    self.time_                 = 0 -- 地图已经运行的时间
    self.lastSecond_           = 0 -- 用于触发 OBJECT_IN_RANGE 事件
    self.dispatchCloseHelp_    = 0
    self.towers_               = {} -- 所有的塔，在玩家触摸时显示开火范围
    self.runtimeC_             = runtimeC -- 碰撞检测引擎
    self.bullets_              = {} -- 所有的子弹对象
    self.skills_               = {} -- 所有的上帝技能对象
    self.racePersonnel_        = {}
    self.raceRank_             = {}
    self.disableList_          = {{}, {}, {}, {}, {}}
    self.decreaseCooldownRate_ = 1 -- 减少上帝技能冷却时间百分比
    self.skillCoolDown_        = {0, 0, 0, 0, 0}
    self.skillNeedTime_        = {0, 0, 0, 0, 0}
    self.colls_                = {} -- 用于 MapRuntimeC
    self.towerDecoration_      = nil -- 塔销毁的状态
    self.selectedTowerObject_  = nil -- 选中的塔的object

    local eventHandlerModuleName = format("data.maps.Map%sEvents", map:getId())
    local eventHandlerModule = require(eventHandlerModuleName)
    self.handler_ = eventHandlerModule.new(self, map)

    require("framework.client.api.EventProtocol").extend(self)
end

function MapRuntime:preparePlay()
    self.handler_:preparePlay()
    self:dispatchEvent({name = MapEvent.MAP_PREPARE_PLAY})

    for id, object in pairs(self.map_:getAllObjects()) do
        object:validate()
        object:preparePlay()
        object:updateView()

        if object:hasBehavior("PlayerBehavior") then
            assert(self.player_ == nil, "MapRuntime:preparePlay() - player more than once")
            self.player_ = object
        end
    end

    assert(self.player_ ~= nil, "MapRuntime:preparePlay() - not set player")
    assert(self.player_:hasBehavior("MovableBehavior") and self.player_:isBinding(),
           "MapRuntime:preparePlay() - player not binding")

    local x, y = self.player_:getPosition()
    self.camera_:setOffset(self.camera_:convertToCameraPosition(x, y))

    self.time_          = 0
    self.lastSecond_    = 0
end

--[[--

开始运行地图

]]
function MapRuntime:startPlay(state)
    self.starting_    = true
    self.over_        = false
    self.paused_      = false
    self.towers_ = {}

    for id, object in pairs(self.map_:getAllObjects()) do
        object:startPlay()
        object.updated__ = true

        if object.classIndex_ == kMapObjectClassIndexStatic
                and object:hasBehavior("TowerBehavior") then
            self.towers_[id] = {
                object.x_ + object.radiusOffsetX_,
                object.y_ + object.radiusOffsetY_,
                object.radius_ + 20,
            }
        end
    end

    if self.player_.genius_["B13"] then
        self.decreaseCooldownRate_ = self.decreaseCooldownRate_ - self.player_.genius_["B13"] / 100
    end

    self.handler_:startPlay(state)
    self:dispatchEvent({name = MapEvent.PLAYER_HP_CHANGED, player = self.player_, isBypassAnimate = true})
    self:dispatchEvent({name = MapEvent.PLAYER_MAGIC_CHANGED, player = self.player_, isBypassAnimate = true})

    if state then
        self:dispatchEvent({name = MapEvent.UI_DISABLE_SHIP_CONTROL, skipAnim = true})

        local delay = MapConstants.RESUME_FROM_PK_DELAY-- + MapConstants.SHIP_DESTROY_ANIM_TIME
        self.paused_ = true
        self.batch_:performWithDelay(function()
            self.paused_ = false
            self:dispatchEvent({name = MapEvent.MAP_START_PLAY})
            self:dispatchEvent({name = MapEvent.UI_ENABLE_SHIP_CONTROL})

            if state.player.isMoving then
                self:startPlayerMoving()
            end
        end, delay)
    else
        self:dispatchEvent({name = MapEvent.MAP_START_PLAY})
    end
end

--[[--

停止运行地图

]]
function MapRuntime:stopPlay()
    for id, object in pairs(self.map_:getAllObjects()) do
        object:stopPlay()
    end

    self.handler_:stopPlay()
    self:dispatchEvent({name = MapEvent.MAP_STOP_PLAY})
    self:removeAllEventListeners()

    self.starting_ = false
end

function MapRuntime:onTouch(event, x, y)
    if self.over_ or self.paused_ or event ~= "began" then return end

    local x, y = self.camera_:convertToMapPosition(x, y)

    if self.godSkillType_ then
        if self:useGodSkill(self.godSkillType_, x, y) then
            self.godSkillType_ = nil
        end
        return false
    end

    for i, crossPoint in pairs(self.map_:getObjectsByClassId("crosspoint")) do
        local crossPoint, index = crossPoint:checkPointIn(x, y)
        if crossPoint then
            if self.map_:getId() == "B0001" and self.dispatchCloseHelp_ == 0 then
                self.dispatchCloseHelp_ = 1
                self:dispatchEvent({
                    name   = MapEvent.UI_REMOVE_PROMPTTARGET,
                })
                if not self:getPlayer():isMoving() then
                    self.batch_:performWithDelay(function()
                        self:dispatchEvent({
                            name   = MapEvent.UI_CREATE_PROMPTTARGET,
                            image  = "#BattleHelp02.png",
                            x      = display.c_left + 273,
                            y      = display.c_bottom + 153
                        })
                    end, 0.1)
                end
            end
            if crossPoint:getSelectedIndex() ~= index then
                crossPoint:setSelectedIndex(index)
                crossPoint:updateView()
            end
            return false
        end
    end

    local minDist = 999999

    if self.map_:isRepairTowerBtnVisible() then
        local repairTowerBtnX, repairTowerBtnY = self.map_:getRepairTowerBtnPosition()
        local dist = math2d.dist(x, y, repairTowerBtnX, repairTowerBtnY)
        if dist < minDist and dist <= MapConstants.REPAIR_TOWER_BTN_RADIUS then
            minDist = dist
            if self.selectedTowerObject_:getHp() == self.selectedTowerObject_:getMaxHp() then
                local mDialog = app.ui.showMessageDialog
                self.map_:getPromptLayer():addChild(mDialog.new("不需要修理", 0.5))
            else
                local mapResult = app.player:getCity():getMapResult()
                local repairTowerGold = mapResult:getDefine().repairTowerGold
                local currentGold = app.player:getGold() - mapResult:getGoldCost()
                if currentGold >= repairTowerGold then
                    if self.selectedTowerObject_:isDestroyed() then
                        self.selectedTowerObject_:hideDestroyedStatus()
                    end
                    self.selectedTowerObject_:setHp(self.selectedTowerObject_:getMaxHp())
                    mapResult:increaseRepairTower()
                    mapResult:setGoldCost(repairTowerGold)
                else
                    local mDialog = app.ui.showMessageDialog
                    self.map_:getPromptLayer():addChild(mDialog.new("金币不足", 0.5))
                end
            end
            return false
        end
    end

    local selectedTowerId
    for id, tower in pairs(self.towers_) do
        local dist = math2d.dist(x, y, tower[1], tower[2])
        if dist < minDist and dist <= tower[3] then
            minDist = dist
            selectedTowerId = id
            self.selectedTowerObject_ = self.map_:getObject(id)
        end
    end

    -- if self.map_:isRepairTowerBtnVisible() then
    --     local repairTowerBtnX, repairTowerBtnY = self.map_:getRepairTowerBtnPosition()
    --     local dist = math2d.dist(x, y, repairTowerBtnX, repairTowerBtnY)
    --     if dist < minDist and dist <= MapConstants.REPAIR_TOWER_BTN_RADIUS then
    --         print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    --         minDist = dist
    --         if self.selectedTowerObject_:getHp() == self.selectedTowerObject_:getMaxHp() then
    --             local mDialog = app.ui.showMessageDialog
    --             self.map_:getPromptLayer():addChild(mDialog.new("不需要修理", 0.5))
    --         else
                -- local mapResult = app.player:getCity():getMapResult()
                -- local repairTowerGold = mapResult:getDefine().repairTowerGold
                -- local currentGold = app.player:getGold() - mapResult:getGoldCost()
                -- if currentGold >= repairTowerGold then
                --     if self.selectedTowerObject_:isDestroyed() then
                --         self.selectedTowerObject_:hideDestroyedStatus()
                --     end
                --     self.selectedTowerObject_:setHp(self.selectedTowerObject_:getMaxHp())
                --     mapResult:increaseRepairTower()
                --     mapResult:setGoldCost(repairTowerGold)
                -- else
                --     local mDialog = app.ui.showMessageDialog
                --     self.map_:getPromptLayer():addChild(mDialog.new("金币不足", 0.5))
                -- end
    --         end
    --     end
    -- end

    if selectedTowerId then
        self.map_:showFireRange(selectedTowerId)
        return false
    else
        self.map_:hideFireRangeAndRepairBtn()
    end
end

function MapRuntime:tick(dt)
    if not self.starting_ or self.paused_ then return end

    local handler = self.handler_

    self.time_ = self.time_ + dt
    local secondsDelta = self.time_ - self.lastSecond_
    if secondsDelta >= 1.0 then
        self.lastSecond_ = self.lastSecond_ + secondsDelta
        if not self.over_ then
            handler:time(self.time_, secondsDelta)
        end
    end

    local maxZOrder = MapConstants.MAX_OBJECT_ZORDER
    for i, object in pairs(self.map_.objects_) do
        if object.tick then
            local lx, ly = object.x_, object.y_
            object:tick(dt)
            object.updated__ = (lx ~= object.x_ or ly ~= object.y_) or (self.godSkillsBinding_ ~= nil)

            if object.updated__ and object.sprite_ and object.viewZOrdered_ then
                self.batch_:reorderChild(object.sprite_, maxZOrder - (object.y_ + object.offsetY_))
            end
        end

        if object.fastUpdateView then
            object:fastUpdateView()
        end
    end

    local events
    if not self.over_ then
        events = self.runtimeC_:tick(self.map_.objects_, self.colls_, dt)
    end

    if events and #events > 0 then
        for i, t in ipairs(events) do
            local event, object1, object2 = t[1], t[2], t[3]
            if event == kMapEventCollisionBegan then
                if object2.classIndex_ == kMapObjectClassIndexRange then
                    handler:objectEnterRange(object1, object2)
                    self:dispatchEvent({name = MapEvent.OBJECT_ENTER_RANGE, object = object1, range = object2})
                else
                    handler:objectCollisionBegan(object1, object2)
                    self:dispatchEvent({
                        name = MapEvent.OBJECT_COLLISION_BEGAN,
                        object1 = object1,
                        object2 = object2,
                    })
                end
            elseif event == kMapEventCollisionEnded then
                if object2.classIndex_ == kMapObjectClassIndexRange then
                    handler:objectExitRange(object1, object2)
                    self:dispatchEvent({name = MapEvent.OBJECT_EXIT_RANGE, object = object1, range = object2})
                else
                    handler:objectCollisionEnded(object1, object2)
                    self:dispatchEvent({
                        name = MapEvent.OBJECT_COLLISION_ENDED,
                        object1 = object1,
                        object2 = object2,
                    })
                end
            elseif event == kMapEventCollisionFire then
                handler:fire(object1, object2)
            elseif event == kMapEventCollisionNoTarget then
                handler:noTarget(object1)
            end
        end
    end

    for i = #self.bullets_, 1, -1 do
        local bullet = self.bullets_[i]
        bullet:tick(dt)
        if bullet:isOver() then
            if bullet:checkHit() then
                handler:hit(bullet.source_, bullet.target_, bullet, self.time_)
            else
                handler:miss(bullet.source_, bullet.target_, bullet)
            end
            bullet:removeView()
            table.remove(self.bullets_, i)
        end
    end

    for i = #self.skills_, 1, -1 do
        local skill = self.skills_[i]
        skill:tick(dt)
        if skill:isOver() then
            if not skill.removed_ then skill:setOver() end
            handler:endGodSkill(skill)
            table.remove(self.skills_, i)
        end
    end

    local skillCoolDown = self.skillCoolDown_
    for i = #skillCoolDown, 1, -1 do
        local times = skillCoolDown[i]
        if times > 0 then
            skillCoolDown[i] = times - dt
        else
            skillCoolDown[i] = 0
        end
    end
end

function MapRuntime:getPlayer()
    return self.player_
end

function MapRuntime:startPlayerMoving()
    self.player_:startMoving()
    self:dispatchEvent({name = MapEvent.PLAYER_START_MOVING})
end

function MapRuntime:stopPlayerMoving()
    self.player_:stopMoving()
    self:dispatchEvent({name = MapEvent.PLAYER_STOP_MOVING})
end

function MapRuntime:getMap()
    return self.map_
end

function MapRuntime:getCamera()
    return self.map_:getCamera()
end

function MapRuntime:getTime()
    return self.time_
end

function MapRuntime:newObject(classId, state, id)
    local object = self.map_:newObject(classId, state, id)
    object:preparePlay()
    if self.starting_ then object:startPlay() end

    if object.sprite_ and object.viewZOrdered_ then
        self.batch_:reorderChild(object.sprite_, MapConstants.MAX_OBJECT_ZORDER - (object.y_ + object.offsetY_))
    end
    object:updateView()

    return object
end

function MapRuntime:newPromptTarget(promptTarget)
    self.promptTarget_ = promptTarget
end

function MapRuntime:removeObject(object)
    object:removeView()
    self.map_:removeObject(object)
end

function MapRuntime:newDecoration(decorationName, target, x, y)
    local decoration = Decoration.new(decorationName)
    decoration:createView(self.batch_)

    local view = decoration:getView()
    if target then
        local targetView = target:getView()
        self.batch_:reorderChild(view, targetView:getZOrder() + decoration.zorder_)
        local ox, oy = tonumber(x), tonumber(y)
        x, y = target:getPosition()
        x = math.floor(x)
        y = math.floor(y)
        view:setPosition(x + ox + decoration.offsetX_, y + oy + decoration.offsetY_)
        view:setScaleX(targetView:getScaleY() * decoration.scale_)
    else
        view:setPosition(x + decoration.offsetX_, y + decoration.offsetY_)
        view:setScaleX(decoration.scale_)
    end

    return decoration
end

function MapRuntime:newShip(state, isMoving)
    local ship = self:newObject("static", state)
    ship:showBornStatus()
    ship:addMovingLock()
    ship:addFireLock()
    audio.playEffect(GAME_SFX.MAP_CREATE_SHIP)
    local waitTime = 1
    if string.sub(self.map_:getId(), 1, 1) == "H" then
        waitTime = 0.1
    end
    local decoration = self:newDecoration("NewShip", ship)
    decoration:playAnimationOnceAndRemove()
    if isMoving then ship:startMoving() end
    self.batch_:performWithDelay(function()
        if ship:isDestroyed() then return end
        if tolua.isnull(ship:getView()) then return end
        ship:removeMovingLock()
        ship:removeFireLock()
    end, waitTime)
    return ship
end

function MapRuntime:returnHomePlayerShip(player, pathId, pointIndex)
    audio.playEffect(GAME_SFX.TRANSMIT_START)

    -- 开始传送时，停止玩家舰船的移动，禁止 UI 控制
    player:stopMovingNow()
    self:stopPlayerMoving()
    self:dispatchEvent({name = MapEvent.UI_DISABLE_SHIP_CONTROL, skipUpdateUI = true, skipAnim = false})

    -- 取得舰船当前的位置，然后将舰船绑定到新位置
    local path = self.map_:getObject(pathId)
    local currentX, currentY = player:getPosition()
    player:bindPath(path, pointIndex)
    local newX, newY = player:getPosition()

    -- 禁止舰船碰撞，禁止开火
    player:addCollisionLock()
    player:addFireLock()

    -- 在当前位置淡出显示舰船
    player:setPosition(currentX, currentY)
    player:fadeTo(0, 1.4)

    -- 播放传送开始的动画
    self:newDecoration("ReturnBasePillar", player):playAnimationOnceAndRemove()
    self:newDecoration("ReturnBaseLights", player):playAnimationOnceAndRemove()
    self:newDecoration("ReturnBaseCircle", player):playAnimationOnceAndRemove()

    self.batch_:performWithDelay(function()
        audio.playEffect(GAME_SFX.TRANSMIT_OVER)

        -- 再一次绑定舰船到新位置，并强制更新视图，确保舰船正确的叠放次序
        player:bindPath(path, pointIndex)
        player:updateView()
        self.batch_:reorderChild(player.sprite_, MapConstants.MAX_OBJECT_ZORDER - (player.y_ + player.offsetY_))

        self.batch_:performWithDelay(function()
            -- 重置摄像机，淡入显示舰船
            self.camera_:setOffsetForPlayer()
            player:fadeTo(255, 0.6)
        end, 0.3)

        self.batch_:performWithDelay(function()
            -- 允许舰船碰撞，允许开火
            player:removeCollisionLock()
            player:removeFireLock()

            -- 允许 UI 控制
            self:dispatchEvent({name = MapEvent.UI_ENABLE_SHIP_CONTROL, skipUpdateUI = true})
        end, 0.8)

        -- 播放传送结束动画
        self:newDecoration("ReturnBasePillarReversed", player):playAnimationOnceAndRemove()
        self:newDecoration("ReturnBaseLightsReversed", player):playAnimationOnceAndRemove()
        self:newDecoration("ReturnBaseCircleReversed", player):playAnimationOnceAndRemove()
    end, 1.4)
end

-- 传送效果(isStop 为nil 或者false 那么传送完成后继续行走)
function MapRuntime:transmitShip(object, pathId, pointIndex, isStop)
    audio.playEffect(GAME_SFX.TRANSMIT_START)

    local path = self.map_:getObject(pathId)
    local ox, oy = object:getPosition()
    object:bindPath(path, pointIndex)

    if isStop then
        object:stopMovingNow()
        if object:isPlayer() then
            self:stopPlayerMoving()
        end
    end
    object:addMovingLock()
    object:addCollisionLock()
    object:addFireLock()
    object:fadeTo(0, 0.4)

    if object:isPlayer() then
        self:dispatchEvent({name = MapEvent.UI_DISABLE_SHIP_CONTROL, skipUpdateUI = true, skipAnim = false})
    end

    local newX, newY = object:getPosition()
    object:setPosition(ox, oy)
    self:newDecoration("EnterVortex", object):playAnimationOnceAndRemove()
    object.x_, object.y_ = newX, newY

    self.batch_:performWithDelay(function()
        audio.playEffect(GAME_SFX.TRANSMIT_OVER)

        object:setPosition(newX, newY)
        object:updateView()
        self.batch_:reorderChild(object.sprite_, MapConstants.MAX_OBJECT_ZORDER - (object.y_ + object.offsetY_))

        self:newDecoration("ExitVortex", object):playAnimationOnceAndRemove()

        self.batch_:performWithDelay(function()
            object:fadeTo(255, 0.4)

            if object:isPlayer() then
                self.camera_:setOffsetForPlayer()
            end
        end, 0.4)

        self.batch_:performWithDelay(function()
            object:removeMovingLock()
            object:removeCollisionLock()
            object:removeFireLock()

            if object:isPlayer() then
                self:dispatchEvent({name = MapEvent.UI_ENABLE_SHIP_CONTROL, skipUpdateUI = true})
            end
        end, 0.6)
    end, 0.5)
end

function MapRuntime:addBullet(bullet)
    self.bullets_[#self.bullets_ + 1] = bullet
end

function MapRuntime:addSkill(skill)
    self.skills_[#self.skills_ + 1]= skill
end

function MapRuntime:prepareUseGodSkill(skillType)
    self.godSkillType_ = skillType
    self.handler_:prepareUseGodSkill(skillType)
    self:dispatchEvent({name = MapEvent.UI_PREPARE_GOD_SKILL, skillType = skillType})
end

function MapRuntime:useGodSkill(skillType, x, y)
    local godSkills = self.player_.godSkills_
    local skillLevel = 1
    if godSkills and godSkills[skillType] then
        skillLevel = godSkills[skillType]
    end
    local skill = GodSkillFactory.newGodSkill(skillType, skillLevel, self, x, y)
    if skill:isSuccess() then
        skill:createView(self.batch_)
        self:addSkill(skill)

        local cooldownIndex = tonumber(string.sub(skillType, -1))
        local cooldown = GodSkillProperties.get(skillType).cooldown[skillLevel]

        self.skillCoolDown_[cooldownIndex] = math.round(cooldown * self.decreaseCooldownRate_)
        self.skillNeedTime_[cooldownIndex] = math.round(cooldown * self.decreaseCooldownRate_)
        self.handler_:useGodSkill(skillType)
        self:dispatchEvent({name = MapEvent.UI_USE_GOD_SKILL, skillType = skillType, cooldown = skill.cooldown})

        return true
    else
        return false
    end
end

function MapRuntime:getSkillCoolDown()
    return self.skillCoolDown_, self.skillNeedTime_
end

function MapRuntime:setSkillCoolDown(coolDown, needTime)
    self.skillCoolDown_ = coolDown
    self.skillNeedTime_ = needTime
end

function MapRuntime:getDisableList()
    return self.disableList_
end

function MapRuntime:prepareToolbox()
    self:pausePlay()
    self:dispatchEvent({name = MapEvent.UI_OPEN_TOOLBOX})
end

function MapRuntime:winGame(player)
    if self.over_ then return end
    self.over_ = true
    self:dispatchEvent({name = MapEvent.MAP_WIN})
    -- self:stopPlay()
    self:pausePlay()
end

function MapRuntime:loseGame(player)
    if self.over_ then return end
    self.over_ = true
    self:dispatchEvent({name = MapEvent.MAP_LOSE})
    -- self:stopPlay()
    self:pausePlay()
end

function MapRuntime:pausePlay()
    if not self.paused_ then
        self:dispatchEvent({name = MapEvent.MAP_PAUSE_PLAY})
    end
    if self.promptTarget_ then
        self.promptTarget_:setVisible(false)
    end
    self.paused_ = true
end

function MapRuntime:resumePlay()
    if self.paused_ then
        self:dispatchEvent({name = MapEvent.MAP_RESUME_PLAY})
    end
    if self.promptTarget_ then
        self.promptTarget_:setVisible(true)
    end
    self.paused_ = false
end

function MapRuntime:runtimeStateDump()
    local all = {}
    for id, object in pairs(self.map_:getAllObjects()) do
        all[id] = object:runtimeStateDump()
    end
    return all
end

function MapRuntime:setRuntimeState(runtimeState)
    for id, state in pairs(runtimeState) do
        local object = self.map_:getObject(id)
        object:setRuntimeState(state)
        object:updateView()
    end
end

function MapRuntime:getRacePersonnel()
    return self.racePersonnel_
end

function MapRuntime:setRacePersonnel(racePersonnel)
    self.racePersonnel_ = racePersonnel
end

function MapRuntime:getRaceRank()
    return self.raceRank_
end

function MapRuntime:setRaceRank(raceRank)
    self.raceRank_ = raceRank
end

function MapRuntime:getCustomState()
    local state = self.handler_:getCustomState()
    state.time           = self.time_
    state.lastSecond     = self.lastSecond_
    state.disableList    = self.disableList_
    state.coolDown       = self.skillCoolDown_
    state.needTime       = self.skillNeedTime_
    return state
end

function MapRuntime:setCustomState(state)
    self.time_          = state.time
    self.lastSecond_    = state.lastSecond
    self.disableList_   = state.disableList
    self.skillCoolDown_ = state.coolDown
    self.skillNeedTime_ = state.needTime
    self.handler_:setCustomState(state)
end

function MapRuntime:changeRundderSpeed(speed)
    self:dispatchEvent({name = MapEvent.CHANGE_RUDDERSPEED, speed_ = speed})
end

function MapRuntime:newLabelText(object, damage, changeType)
    local view = object:getView()
    local x, y = view:getPosition()
    local change = "-"
    if changeType == "decreaseMagic" then
        changeType = BATTLE_FONT_BLUE
    elseif changeType == "addMagic" then
        changeType = BATTLE_FONT_BLUE
        change = "+"
    elseif changeType == "decreaseHp" then
        changeType = BATTLE_FONT_RED
    elseif changeType == "addHp" then
        changeType = BATTLE_FONT_GREEN
        change = "+"
    end
    local hitText = ui.newBMFontLabel({
        font = changeType,
        text = change..damage,
        x    = x,
        y    = y + 30,
    })
    self.map_:getMarksLayer():addChild(hitText, MapConstants.BULLET_ZORDER + 1)

    hitText:setScale(0.1)
    transition.moveBy(hitText, {y = 40, time = 0.8})
    transition.scaleTo(hitText, {scale = 1.2, time = 0.4, easing = "ELASTICOUT"})
    transition.fadeOut(hitText, {delay = 0.8, time = 0.4, onComplete = function()
        if not tolua.isnull(hitText) then
            hitText:removeSelf()
        end
    end})
end

return MapRuntime

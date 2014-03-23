
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

    local eventHandlerModuleName = string.format("maps.Map%sEvents", map:getId())
    local eventHandlerModule = require(eventHandlerModuleName)
    self.handler_ = eventHandlerModule.new(self, map)

    require("framework.api.EventProtocol").extend(self)
end

function MapRuntime:preparePlay()
    self.handler_:preparePlay()
    self:dispatchEvent({name = MapEvent.MAP_PREPARE_PLAY})

    for id, object in pairs(self.map_:getAllObjects()) do
        object:validate()
        object:preparePlay()
        object:updateView()
    end

    self.camera_:setOffset(0, 0)

    self.time_          = 0
    self.lastSecond_    = 0
end

--[[--

开始运行地图

]]
function MapRuntime:startPlay()
    self.starting_    = true
    self.over_        = false
    self.paused_      = false
    self.towers_ = {}

    for id, object in pairs(self.map_:getAllObjects()) do
        object:startPlay()
        object.updated__ = true

        if object.classIndex_ == kMapObjectClassIndexStatic and object:hasBehavior("TowerBehavior") then
            self.towers_[id] = {
                object.x_ + object.radiusOffsetX_,
                object.y_ + object.radiusOffsetY_,
                object.radius_ + 20,
            }
        end
    end

    self.handler_:startPlay(state)
    self:dispatchEvent({name = MapEvent.MAP_START_PLAY})
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

    -- 将触摸的屏幕坐标转换为地图坐标
    local x, y = self.camera_:convertToMapPosition(x, y)
    local minDist = 999999

    -- 检查是否选中了某个塔
    local selectedTowerId
    for id, tower in pairs(self.towers_) do
        local dist = math2d.dist(x, y, tower[1], tower[2])
        if dist < minDist and dist <= tower[3] then
            minDist = dist
            selectedTowerId = id
        end
    end

    if selectedTowerId then
        -- 对选中的塔做操作
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

    -- 更新所有对象后
    local maxZOrder = MapConstants.MAX_OBJECT_ZORDER
    for i, object in pairs(self.map_.objects_) do
        if object.tick then
            local lx, ly = object.x_, object.y_
            object:tick(dt)
            object.updated__ = lx ~= object.x_ or ly ~= object.y_

            -- 只有当对象的位置发生变化时才调整对象的 ZOrder
            if object.updated__ and object.sprite_ and object.viewZOrdered_ then
                self.batch_:reorderChild(object.sprite_, maxZOrder - (object.y_ + object.offsetY_))
            end
        end

        if object.fastUpdateView then
            object:fastUpdateView()
        end
    end

    -- 通过碰撞引擎获得事件
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

    -- 更新所有的子弹对象
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

--[[--

用于运行时创建新对象并放入地图

]]
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

function MapRuntime:removeObject(object)
    object:removeView()
    self.map_:removeObject(object)
end

--[[--

创建一个装饰对象并放入地图

]]
function MapRuntime:newDecoration(decorationName, target, x, y)
    local decoration = Decoration.new(decorationName)
    decoration:createView(self.batch_)

    local view = decoration:getView()
    if target then
        local targetView = target:getView()
        self.batch_:reorderChild(view, targetView:getZOrder() + decoration.zorder_)
        local ox, oy = tonum(x), tonum(y)
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

function MapRuntime:addBullet(bullet)
    self.bullets_[#self.bullets_ + 1] = bullet
end

function MapRuntime:winGame(player)
    if self.over_ then return end
    self.over_ = true
    self:dispatchEvent({name = MapEvent.MAP_WIN})
    self:pausePlay()
end

function MapRuntime:loseGame(player)
    if self.over_ then return end
    self.over_ = true
    self:dispatchEvent({name = MapEvent.MAP_LOSE})
    self:pausePlay()
end

function MapRuntime:pausePlay()
    if not self.paused_ then
        self:dispatchEvent({name = MapEvent.MAP_PAUSE_PLAY})
    end
    self.paused_ = true
end

function MapRuntime:resumePlay()
    if self.paused_ then
        self:dispatchEvent({name = MapEvent.MAP_RESUME_PLAY})
    end
    self.paused_ = false
end

return MapRuntime

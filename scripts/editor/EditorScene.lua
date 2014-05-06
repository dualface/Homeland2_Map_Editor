
local LEVEL_ID = "A0002"

local EditorConstants = require("editor.EditorConstants")

--[[--

编辑器场景

]]
local EditorScene = class("EditorScene", function()
    return display.newScene("EditorScene")
end)

function EditorScene:ctor()
    local bg = display.newTilesSprite("EditorBg.png")
    self:addChild(bg)

    -- mapLayer 包含地图的整个视图
    self.mapLayer_ = display.newNode()
    self.mapLayer_:align(display.LEFT_BOTTOM, 0, 0)
    self:addChild(self.mapLayer_)

    -- touchLayer 用于接收触摸事件
    self.touchLayer_ = display.newLayer()
    self:addChild(self.touchLayer_)

    -- uiLayer 用于显示编辑器的 UI（工具栏等）
    self.uiLayer_ = display.newNode()
    self.uiLayer_:setPosition(display.cx, display.cy)
    self:addChild(self.uiLayer_)

    -- 创建地图对象
    self.map_ = require("app.map.Map").new(LEVEL_ID, true) -- 参数：地图ID, 是否是编辑器模式
    self.map_:init()
    self.map_:createView(self.mapLayer_)

    -- 创建工具栏
    self.toolbar_ = require("editor.Toolbar").new(self.map_)
    self.toolbar_:addTool(require("editor.GeneralTool").new(self.toolbar_, self.map_))
    self.toolbar_:addTool(require("editor.ObjectTool").new(self.toolbar_, self.map_))
    self.toolbar_:addTool(require("editor.PathTool").new(self.toolbar_, self.map_))
    self.toolbar_:addTool(require("editor.RangeTool").new(self.toolbar_, self.map_))

    -- 创建工具栏的视图
    self.toolbarView_ = self.toolbar_:createView(self.uiLayer_, "#ToolbarBg.png", 40)
    self.toolbarView_:setPosition(display.c_left, display.c_bottom)
    self.toolbar_:setDefaultTouchTool("GeneralTool")
    self.toolbar_:selectButton("GeneralTool", 1)

    -- 创建对象信息面板
    self.objectInspector_ = require("editor.ObjectInspector").new(self.map_)
    self.objectInspector_:addEventListener("UPDATE_OBJECT", function(event)
        self.toolbar_:dispatchEvent(event)
    end)
    self.objectInspector_:createView(self.uiLayer_)

    -- 创建地图名称文字标签
    self.mapNameLabel_ = ui.newTTFLabelWithOutline({
        text  = string.format("module: %s, image: %s", self.map_.mapModuleName_, self.map_.imageName_),
        size  = 16,
        align = ui.TEXT_ALIGN_LEFT,
        x     = display.left + 10,
        y     = display.bottom + EditorConstants.MAP_TOOLBAR_HEIGHT + 20,
    })
    self.mapLayer_:addChild(self.mapNameLabel_)

    -- 注册工具栏事件
    self.toolbar_:addEventListener("SELECT_OBJECT", function(event)
        self.objectInspector_:setObject(event.object)
    end)
    self.toolbar_:addEventListener("UPDATE_OBJECT", function(event)
        self.objectInspector_:setObject(event.object)
    end)
    self.toolbar_:addEventListener("UNSELECT_OBJECT", function(event)
        self.objectInspector_:removeObject()
    end)
    self.toolbar_:addEventListener("PLAY_MAP", function()
        self:playMap()
    end)

    -- 创建运行地图时的工具栏
    local toggleDebugButton = ui.newImageMenuItem({
        image         = "#ToggleDebugButton.png",
        imageSelected = "#ToggleDebugButtonSelected.png",
        x             = display.left + 26,
        y             = display.top - 26,
        listener      = function()
            local debugLayer = self.map_:getDebugLayer()
            debugLayer:setVisible(not debugLayer:isVisible())
        end
    })

    local stopMapButton = ui.newImageMenuItem({
        image         = "#StopMapButton.png",
        imageSelected = "#StopMapButtonSelected.png",
        x             = display.left + 72,
        y             = display.top - 26,
        listener      = function() self:editMap() end
    })

    self.playToolbar_ = ui.newMenu({toggleDebugButton, stopMapButton})
    self.playToolbar_:setVisible(false)
    self:addChild(self.playToolbar_)

    -- if device.platform == "ios" or device.platform == "android" then
    --     -- 如果是在真机上运行，就直接开始播放地图，不再使用编辑器
    --     self:playMap()
    -- else
        self:editMap()
    -- end
end

-- 开始运行地图
function EditorScene:playMap()
    CCDirector:sharedDirector():setDisplayStats(true)

    -- 隐藏编辑器界面
    self.toolbar_:getView():setVisible(false)

    -- if device.platform == "ios" or device.platform == "android" then
    --     -- 真机上禁止编辑器工具栏
    --     self.playToolbar_:setVisible(false)
    -- else
        -- 模拟器上保存地图当前状态
        self.mapState_ = self.map_:vardump()
        self.playToolbar_:setVisible(true)
    -- end
    self.mapNameLabel_:setVisible(false)

    self.map_:getBackgroundLayer():setVisible(true)
    self.map_:getBackgroundLayer():setOpacity(255)
    if self.map_:getDebugLayer() then
        self.map_:getDebugLayer():setVisible(false)
    end

    local camera = self.map_:getCamera()
    camera:setMargin(0, 0, 0, 0)
    camera:setOffset(0, 0)

    self.mapRuntime_ = require("app.map.MapRuntime").new(self.map_)
    self.mapRuntime_:preparePlay()
    self.mapRuntime_:startPlay()
    self:addChild(self.mapRuntime_)
end

-- 开始编辑地图
function EditorScene:editMap()
    CCDirector:sharedDirector():setDisplayStats(false)

    if self.mapRuntime_ then
        self.mapRuntime_:stopPlay()
        self.mapRuntime_:removeSelf()
        self.mapRuntime_ = nil
    end

    if self.mapState_ then
        -- 重置地图状态
        self.map_:reset(self.mapState_)
        self.map_:createView(self.mapLayer_)
        self.mapState_ = nil
    end

    self.toolbar_:getView():setVisible(true)
    self.playToolbar_:setVisible(false)
    self.mapNameLabel_:setVisible(true)
    if self.map_:getDebugLayer() then
        self.map_:getDebugLayer():setVisible(true)
    end

    local camera = self.map_:getCamera()
    camera:setMargin(EditorConstants.MAP_PADDING,
                     EditorConstants.MAP_PADDING,
                     EditorConstants.MAP_PADDING + EditorConstants.MAP_TOOLBAR_HEIGHT + 20,
                     EditorConstants.MAP_PADDING)
    camera:setScale(1)
    camera:setOffset(0, 0)
end

function EditorScene:tick(dt)
    if self.mapRuntime_ then
        self.mapRuntime_:tick(dt)
    end
end

function EditorScene:onTouch(event, x, y)
    if self.mapRuntime_ then
        -- 如果正在运行地图，将触摸事件传递到地图
        if self.mapRuntime_:onTouch(event, x, y, map) == true then
            return true
        end

        if event == "began" then
            self.drag = {
                startX  = x,
                startY  = y,
                lastX   = x,
                lastY   = y,
                offsetX = 0,
                offsetY = 0,
            }
            return true
        end

        if event == "moved" then
            self.drag.offsetX = x - self.drag.lastX
            self.drag.offsetY = y - self.drag.lastY
            self.drag.lastX = x
            self.drag.lastY = y
            self.map_:getCamera():moveOffset(self.drag.offsetX, self.drag.offsetY)

        else -- "ended" or CCTOUCHCANCELLED
            self.drag = nil
        end

        return
    end

    -- 如果没有运行地图，则将事件传递到工具栏
    x, y = math.round(x), math.round(y)
    if event == "began" then
        if self.objectInspector_:getView():isVisible() and self.objectInspector_:checkPointIn(x, y) then
            return self.objectInspector_:onTouch(event, x, y)
        end
    end

    return self.toolbar_:onTouch(event, x, y)
end

function EditorScene:onEnter()
    self.touchLayer_:registerScriptTouchHandler(function(event, x, y)
        return self:onTouch(event, x, y)
    end)
    self.touchLayer_:setTouchEnabled(true)
    self:scheduleUpdate(function(dt) self:tick(dt) end)
end

function EditorScene:onExit()
    if self.mapRuntime_ then
        self.mapRuntime_:stopPlay()
    end

    self.objectInspector_:removeAllEventListeners()
    self.toolbar_:removeAllEventListeners()
end

return EditorScene

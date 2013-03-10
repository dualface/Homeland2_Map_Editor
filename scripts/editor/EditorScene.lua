
local LEVEL_ID = "A0001"

local EditorConstants = require("editor.EditorConstants")

--[[--

编辑器场景

]]
local EditorScene = class("EditorScene", function()
    return display.newScene("EditorScene")
end)

function EditorScene:ctor()
    local bg = display.newBackgroundTilesSprite("EditorBg.png")
    self:addChild(bg)

    -- mapLayer 包含地图的整个视图
    self.mapLayer = display.newNode()
    self.mapLayer:align(display.LEFT_BOTTOM, 0, 0)
    self:addChild(self.mapLayer)

    -- touchLayer 用于接收触摸事件
    self.touchLayer = display.newLayer()
    self:addChild(self.touchLayer)

    -- uiLayer 用于显示编辑器的 UI（工具栏等）
    self.uiLayer = display.newNode()
    self.uiLayer:setPosition(display.cx, display.cy)
    self:addChild(self.uiLayer)

    -- 创建地图对象
    self.map = require("app.map.Map").new(LEVEL_ID, true) -- 参数：地图ID, 是否是编辑器模式
    self.map:init()
    self.map:createView(self.mapLayer)

    -- 创建工具栏
    self.toolbar = require("editor.Toolbar").new(self.map)
    self.toolbar:addTool(require("editor.GeneralTool").new(self.toolbar, self.map))
    self.toolbar:addTool(require("editor.ObjectTool").new(self.toolbar, self.map))
    self.toolbar:addTool(require("editor.PathTool").new(self.toolbar, self.map))
    self.toolbar:addTool(require("editor.RangeTool").new(self.toolbar, self.map))

    -- 创建工具栏的视图
    self.toolbarView = self.toolbar:createView(self.uiLayer, "#ToolbarBg.png", 40)
    self.toolbarView:setPosition(display.c_left, display.c_bottom)
    self.toolbar:setDefaultTouchTool("GeneralTool")
    self.toolbar:selectButton("GeneralTool", 1)

    -- 创建对象信息面板
    self.objectInspector = require("editor.ObjectInspector").new(self.map)
    self.objectInspector:addEventListener("UPDATE_OBJECT", function(event)
        self.toolbar:dispatchEvent(event)
    end)
    self.objectInspector:createView(self.uiLayer)

    -- 创建地图名称文字标签
    self.mapNameLabel = ui.newTTFLabelWithOutline({
        text  = format("module: %s, image: %s", self.map.mapModuleName_, self.map.imageName_),
        size  = 16,
        align = ui.TEXT_ALIGN_LEFT,
        x     = display.left + 10,
        y     = display.bottom + EditorConstants.MAP_TOOLBAR_HEIGHT + 20,
    })
    self.mapLayer:addChild(self.mapNameLabel)

    -- 注册工具栏事件
    self.toolbar:addEventListener("SELECT_OBJECT", function(event)
        self.objectInspector:setObject(event.object)
    end)
    self.toolbar:addEventListener("UPDATE_OBJECT", function(event)
        self.objectInspector:setObject(event.object)
    end)
    self.toolbar:addEventListener("UNSELECT_OBJECT", function(event)
        self.objectInspector:removeObject()
    end)
    self.toolbar:addEventListener("PLAY_MAP", function()
        self:playMap()
    end)

    -- 创建运行地图时的工具栏
    local toggleDebugButton = ui.newImageMenuItem({
        image         = "#ToggleDebugButton.png",
        imageSelected = "#ToggleDebugButtonSelected.png",
        x             = display.left + 26,
        y             = display.top - 26,
        listener      = function()
            local debugLayer = self.map:getDebugLayer()
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

    self.playToolbar = ui.newMenu({toggleDebugButton, stopMapButton})
    self.playToolbar:setVisible(false)
    self:addChild(self.playToolbar)

    self:editMap()
end

-- 开始运行地图
function EditorScene:playMap()
    -- 隐藏编辑器界面
    self.toolbar:getView():setVisible(false)
    self.playToolbar:setVisible(true)
    self.mapNameLabel:setVisible(false)

    self.map:getBackgroundLayer():setVisible(true)
    self.map:getBackgroundLayer():setOpacity(255)
    if self.map:getDebugLayer() then
        self.map:getDebugLayer():setVisible(false)
    end

    local camera = self.map:getCamera()
    camera:setMargin(0, 0, 0, 0)
    camera:setOffset(0, 0)

    self.mapRuntimeC = MapRuntimeC:create()
    self:addChild(self.mapRuntimeC)

    self.mapRuntime = require("app.map.MapRuntime").new(self.map, self.mapRuntimeC)
    self.mapRuntime:preparePlay()
    self.mapRuntime:startPlay()
end

-- 开始编辑地图
function EditorScene:editMap()
    if self.mapRuntime then
        self.mapRuntime:stopPlay()
        self.mapRuntime = nil
    end

    if self.mapRuntimeC then
        self.mapRuntimeC:removeFromParentAndCleanup(true)
        self.mapRuntimeC = nil
    end

    self.toolbar:getView():setVisible(true)
    self.playToolbar:setVisible(false)
    self.mapNameLabel:setVisible(true)
    if self.map:getDebugLayer() then
        self.map:getDebugLayer():setVisible(true)
    end

    local camera = self.map:getCamera()
    camera:setMargin(EditorConstants.MAP_PADDING,
                     EditorConstants.MAP_PADDING,
                     EditorConstants.MAP_PADDING + EditorConstants.MAP_TOOLBAR_HEIGHT + 20,
                     EditorConstants.MAP_PADDING)
    camera:setScale(1)
    camera:setOffset(0, 0)
end

function EditorScene:tick(dt)
    if self.mapRuntime then
        self.mapRuntime:tick(dt)
    end
end

function EditorScene:onTouch(event, x, y)
    if self.mapRuntime then
        -- 如果正在运行地图，将触摸事件传递到地图
        if self.mapRuntime:onTouch(event, x, y, map) == true then
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
            self.map:getCamera():moveOffset(self.drag.offsetX, self.drag.offsetY)

        else -- "ended" or CCTOUCHCANCELLED
            self.drag = nil
        end

        return
    end

    -- 如果没有运行地图，则将事件传递到工具栏
    x, y = math.round(x), math.round(y)
    if event == "began" then
        if self.objectInspector:getView():isVisible() and self.objectInspector:checkPointIn(x, y) then
            return self.objectInspector:onTouch(event, x, y)
        end
    end

    return self.toolbar:onTouch(event, x, y)
end

function EditorScene:onEnter()
    self.touchLayer:registerScriptTouchHandler(function(event, x, y)
        return self:onTouch(event, x, y)
    end)
    self.touchLayer:setTouchEnabled(true)
    self:scheduleUpdate(function(dt) self:tick(dt) end)
end

function EditorScene:onExit()
    if self.mapRuntime then self.mapRuntime:stopPlay() end

    self.objectInspector:removeAllEventListeners()
    self.toolbar:removeAllEventListeners()
end

return EditorScene

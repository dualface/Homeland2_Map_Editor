
local AutoLayout = require("editor.AutoLayout")
local ToolBase   = require("editor.ToolBase")

local Toolbar = class("Toolbar")

function Toolbar:ctor(map)
    require("framework.api.EventProtocol").extend(self)

    self.map_                = map
    self.tools_              = {}
    self.toolsName_          = {}

    self.toolbarHeight_      = 0
    self.defaultTouchTool_   = nil

    self.currentToolName_    = nil
    self.currentButtonIndex_ = nil
    self.sprite_             = nil

    self.isDefaultTouch_     = false

    require("framework.api.EventProtocol").extend(self)
end

function Toolbar:onTouch(event, x, y)
    if y > self.toolbarHeight_ then
        local ret
        if self.isDefaultTouch_ then
            ret = self.tools_[self.defaultTouchTool_]:onIgnoredTouch(event, x, y, true)
            if ret == ToolBase.DEFAULT_TOUCH_ENDED then
                self.isDefaultTouch_ = false
                ret = false
            end
        else
            ret = self.tools_[self.currentToolName_]:onTouch(event, x, y)
            if ret == ToolBase.TOUCH_IGNORED and self.defaultTouchTool_ then
                ret = self.tools_[self.defaultTouchTool_]:onIgnoredTouch(event, x, y, true)
                if ret == true then
                    self.isDefaultTouch_ = true
                end
            end
        end
        return ret
    end
end

function Toolbar:onButtonTap(selectedTool, selectedButton)
    for toolName, tool in pairs(self.tools_) do
        if tool ~= selectedTool then tool:unselected() end
        for buttonIndex, button in ipairs(tool.buttons) do
            if button == selectedButton then
                self.currentButtonIndex_ = buttonIndex
            elseif button.sprite:isEnabled() then
                button.sprite:unselected()
            end
        end
    end

    self.currentToolName_ = selectedTool:getName()
    selectedButton.sprite:selected()
    selectedTool:selected(selectedButton.name)

    self:dispatchEvent({
        name       = "SELECT_TOOL",
        toolName   = self.currentToolName_,
        buttonName = selectedButton.name,
    })
end

function Toolbar:createView(parent, bgImageName, padding, scale, toolbarLines)
    if self.sprite_ then return end

    self.sprite_ = display.newNode()
    local bg = display.newSprite(bgImageName)
    bg:setScaleX((display.width / bg:getContentSize().width) * 2)
    bg:setScaleY(scale * toolbarLines)
    bg:align(display.CENTER_BOTTOM, display.cx, 0)
    self.toolbarHeight_ = bg:getContentSize().height * scale
    self.sprite_:addChild(bg)

    local items = {}
    for toolIndex, toolName in ipairs(self.toolsName_) do
        if toolbarLines > 1 and toolIndex == 3 then
            items[#items + 1] = "#"
        elseif toolIndex > 1 then
            items[#items + 1] = "-"
        end

        local tool = self.tools_[toolName]
        for buttonIndex, button in ipairs(tool.buttons) do
            button.listener = function() self:onButtonTap(tool, button) end
            button.sprite = ui.newImageMenuItem(button)
            button.sprite:setScale(scale)
            items[#items + 1] = button.sprite
        end
    end

    local menu = ui.newMenu(items)
    self.sprite_:addChild(menu)
    AutoLayout.alignItemsHorizontally(items, padding * scale, self.toolbarHeight_ / 2, padding * scale, toolbarLines)

    -- 放大缩小按钮
    local zoomInButton = ui.newImageMenuItem({
        image    = "#ZoomInButton.png",
        x        = display.right - 72 * scale,
        y        = self.toolbarHeight_ / 2,
        listener = function()
            local scale = self.map_:getCamera():getScale()
            if scale < 2.0 then
                scale = scale + 0.5
                if scale > 2.0 then scale = 2.0 end
                self.map_:getCamera():setScale(scale)
                self.map_:updateView()
                self.scaleLabel_:setString(string.format("%0.2f", scale))
            end
        end
    })
    zoomInButton:setScale(scale)

    local zoomOutButton = ui.newImageMenuItem({
        image    = "#ZoomOutButton.png",
        x        = display.right - 28 * scale,
        y        = self.toolbarHeight_ / 2,
        listener = function()
            local scale = self.map_:getCamera():getScale()
            if scale > 0.5 then
                scale = scale - 0.5
                if scale < 0.5 then scale = 0.5 end
                self.map_:getCamera():setScale(scale)
                self.map_:updateView()
                self.scaleLabel_:setString(string.format("%0.2f", scale))
            end
        end
    })
    zoomOutButton:setScale(scale)

    local zoombar = ui.newMenu({zoomInButton, zoomOutButton})
    self.sprite_:addChild(zoombar)

    self.scaleLabel_ = ui.newTTFLabel({
        text  = "1.00",
        font  = ui.DEFAULT_TTF_FONT,
        size  = 24 * scale,
        color = ccc3(255, 255, 255),
        align = ui.TEXT_ALIGN_RIGHT,
        x     = display.right - 96 * scale,
        y     = self.toolbarHeight_ / 2,
    })
    self.sprite_:addChild(self.scaleLabel_)

    parent:addChild(self.sprite_)

    self.sprite_:registerScriptHandler(function(event)
        if event == "exit" then
            self:removeAllEventListeners()
        end
    end)

    return self.sprite_
end

function Toolbar:getView()
    return self.sprite_
end

function Toolbar:addTool(tool)
    self.tools_[tool:getName()] = tool
    self.toolsName_[#self.toolsName_ + 1] = tool:getName()
end

function Toolbar:setDefaultTouchTool(toolName)
    self.defaultTouchTool_ = toolName
end

function Toolbar:selectButton(toolName, buttonIndex)
    assert(self.sprite_, "Toolbar sprites not created")
    self:onButtonTap(self.tools_[toolName], self.tools_[toolName].buttons[buttonIndex])
end

function Toolbar:getSelectedButtonName()
    return self.tools_[self.currentToolName_].buttons[self.currentButtonIndex_].name
end

function Toolbar:showNotice(text, fontsize, delay)
    local label = ui.newTTFLabel({
        text = "Save map ok",
        size = fontsize or 96,
        color = ccc3(100, 255, 100),
        align = ui.TEXT_ALIGN_CENTER,
    })

    label:setPosition(display.cx, display.cy)
    self:getView():addChild(label)

    transition.moveBy(label, {y = 20, time = 1.0, delay = delay or 0.5})
    transition.fadeOut(label, {time = 1.0, delay = delay or 0.5, onComplete = function()
        label:removeSelf()
    end})
end

return Toolbar

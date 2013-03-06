
local MapConstants    = require("app.map.MapConstants")
local EditorConstants = require("editor.EditorConstants")

local PathInspector = class("PathInspector")

PathInspector.POSITION_LEFT_TOP     = "LEFT_TOP"
PathInspector.POSITION_RIGHT_TOP    = "RIGHT_TOP"
PathInspector.POSITION_LEFT_BOTTOM  = "LEFT_BOTTOM"
PathInspector.POSITION_RIGHT_BOTTOM = "RIGHT_BOTTOM"

PathInspector.ALL_POSITIONS = {
    PathInspector.POSITION_LEFT_TOP,
    PathInspector.POSITION_RIGHT_TOP,
    PathInspector.POSITION_RIGHT_BOTTOM,
    PathInspector.POSITION_LEFT_BOTTOM,
}

function PathInspector:ctor(map)
    self.map_            = map
    self.sprite_         = nil
    self.bg_             = nil
    self.size_           = {0, 0}
    self.position_       = PathInspector.POSITION_RIGHT_BOTTOM
    self.object_         = nil
    self.isVisible_      = true

    require("framework.client.api.EventProtocol").extend(self)
end


function PathInspector:checkPointIn(x, y)
    local worldPosition = self.sprite_:convertToWorldSpace(ccp(0, 0))
    local wx, wy = worldPosition.x, worldPosition.y

    return x >= wx
            and x <= wx + self.size_[1]
            and y <= wy
            and y >= wy - self.size_[2]
end

function PathInspector:onTouch(event, x, y)
    if event ~= "began" then return false end

    local worldPosition = self.sprite_:convertToWorldSpace(ccp(0, 0))
    local wx, wy = worldPosition.x, worldPosition.y
    x = x - wx
    y = y - wy

    local width, height = unpack(self.size_)
    local offset = EditorConstants.PANEL_BUTTON_OFFSET
    local size = EditorConstants.PANEL_BUTTON_SIZE
    if x >= width - size - offset and x <= width - offset and y <= -offset and y >= -offset - size then
        for i, pos in ipairs(PathInspector.ALL_POSITIONS) do
            if self.position_ == pos then
                i = i + 1
                if i > #PathInspector.ALL_POSITIONS then
                    i = 1
                end
                self.position_ = PathInspector.ALL_POSITIONS[i]
                self:setPosition()
                break
            end
        end
        return false
    end
end

function PathInspector:getView()
    return self.sprite_
end

function PathInspector:createView(parent, object)
    local layer = display.newNode()
    local bg = display.newSprite("#EditorPanelBg.png")
    local size = bg:getContentSize()
    bg:align(display.LEFT_TOP, 0, 0)
    bg:getTexture():setAliasTexParameters()
    layer:addChild(bg)
    layer:setVisible(false)
    parent:addChild(layer)

    local offset = EditorConstants.PANEL_BUTTON_SIZE / 2 + EditorConstants.PANEL_BUTTON_OFFSET
    self.positionButton_ = display.newSprite("#EditorPanelPositionButton.png")
    self.positionButton_:setPosition(0, -offset)
    layer:addChild(self.positionButton_)

    self.bg_ = bg
    self.sprite_ = layer
    return layer
end

function PathInspector:removeView()
    if self.sprite_ then
        self.sprite_:removeSelf()
        self.sprite_ = nil
    end
end

function PathInspector:setPosition()
    local width, height = unpack(self.size_)

    local size = self.bg_:getContentSize()
    self.bg_:setScaleX(width / size.width)
    self.bg_:setScaleY(height / size.height)

    local offset = EditorConstants.PANEL_OFFSET

    if self.position_ == PathInspector.POSITION_LEFT_TOP then
        self.sprite_:align(display.LEFT_TOP,
                           display.c_left + offset,
                           display.c_top - offset)
    elseif self.position_ == PathInspector.POSITION_RIGHT_TOP then
        self.sprite_:align(display.LEFT_TOP,
                           display.c_right - width - offset,
                           display.c_top - offset)
    elseif self.position_ == PathInspector.POSITION_LEFT_BOTTOM then
        self.sprite_:align(display.LEFT_TOP,
                           display.c_left + offset,
                           display.c_bottom + height + EditorConstants.MAP_TOOLBAR_HEIGHT + offset)
    else
        self.sprite_:align(display.LEFT_TOP,
                           display.c_right - width - offset,
                           display.c_bottom + height + EditorConstants.MAP_TOOLBAR_HEIGHT + offset)
    end

    local offset = EditorConstants.PANEL_BUTTON_SIZE / 2 + EditorConstants.PANEL_BUTTON_OFFSET
    self.positionButton_:setPositionX(width - offset)
end

function PathInspector:show()
    self.size_ = {EditorConstants.PATH_INSPECTOR_WIDTH, 100}
    self:setPosition()
    self.sprite_:setVisible(true)
end

function PathInspector:hide()
    self.sprite_:setVisible(false)
end

return PathInspector

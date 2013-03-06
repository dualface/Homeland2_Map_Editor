
local MapConstants    = require("app.map.MapConstants")
local BehaviorFactory = require("app.map.behaviors.BehaviorFactory")
local EditorConstants = require("editor.EditorConstants")

local ObjectInspector = class("ObjectInspector")

ObjectInspector.EditButtonSize        = 16

ObjectInspector.POSITION_LEFT_TOP     = "LEFT_TOP"
ObjectInspector.POSITION_RIGHT_TOP    = "RIGHT_TOP"
ObjectInspector.POSITION_LEFT_BOTTOM  = "LEFT_BOTTOM"
ObjectInspector.POSITION_RIGHT_BOTTOM = "RIGHT_BOTTOM"

ObjectInspector.ALL_POSITIONS = {
    ObjectInspector.POSITION_LEFT_TOP,
    ObjectInspector.POSITION_RIGHT_TOP,
    ObjectInspector.POSITION_RIGHT_BOTTOM,
    ObjectInspector.POSITION_LEFT_BOTTOM,
}

function ObjectInspector:ctor(map)
    self.map_            = map
    self.sprite_         = nil
    self.bg_             = nil
    self.size_           = {0, 0}
    self.position_       = ObjectInspector.POSITION_RIGHT_BOTTOM
    self.behaviorsLabel_ = {}
    self.object_         = nil
    self.editButtons_    = {}
    self.isVisible_      = true

    require("framework.client.api.EventProtocol").extend(self)
end

function ObjectInspector:checkPointIn(x, y)
    local worldPosition = self.sprite_:convertToWorldSpace(ccp(0, 0))
    local wx, wy = worldPosition.x, worldPosition.y

    return x >= wx
            and x <= wx + self.size_[1]
            and y <= wy
            and y >= wy - self.size_[2]
end

function ObjectInspector:onTouch(event, x, y)
    if event ~= "began" then return false end

    local worldPosition = self.sprite_:convertToWorldSpace(ccp(0, 0))
    local wx, wy = worldPosition.x, worldPosition.y
    x = x - wx
    y = y - wy

    local width, height = unpack(self.size_)
    local offset = EditorConstants.PANEL_BUTTON_OFFSET
    local size = EditorConstants.PANEL_BUTTON_SIZE
    if x >= offset and x <= offset + size and y <= -offset and y >= -offset - size then
        self.sprite_:setVisible(false)
        self.isVisible_ = false
        return false
    elseif x >= width - size - offset and x <= width - offset and y <= -offset and y >= -offset - size then
        for i, pos in ipairs(ObjectInspector.ALL_POSITIONS) do
            if self.position_ == pos then
                i = i + 1
                if i > #ObjectInspector.ALL_POSITIONS then
                    i = 1
                end
                self.position_ = ObjectInspector.ALL_POSITIONS[i]
                self:setPosition()
                break
            end
        end
        return false
    end

    local function updateObject(changeFunction)
        self.object_:removeView()
        changeFunction()
        self.object_:resetAllBehaviors()
        self.object_:createView(self.map_:getBatchLayer(),
                                self.map_:getMarksLayer(),
                                self.map_:getDebugLayer())
        self.object_:updateView()
        self:setObject(self.object_)

        self:dispatchEvent({name = "UPDATE_OBJECT", object = self.object_})
    end

    for i, behavior in ipairs(BehaviorFactory.getAllStaticObjectBehaviorsName()) do
        local label = self.behaviorsLabel_[i]
        if x >= label.x
                and x <= label.x + label.width
                and y <= label.y
                and y >= label.y - label.height then

            if label.isLocked then return false end

            updateObject(function()
                if self.object_:hasBehavior(behavior) then
                    self.object_:unbindBehavior(behavior)
                    label.sprite:setOpacity(64)
                else
                    self.object_:bindBehavior(behavior)
                    label.sprite:setOpacity(255)
                end
                self.object_:validate()
            end)

            return false
        end
    end

    local bsize = ObjectInspector.EditButtonSize / 2
    for i, button in pairs(self.editButtons_) do
        if x >= button.x - bsize and x <= button.x + bsize and y <= button.y + bsize and y >= button.y - bsize then
            local message = format("Enter new [%s] value.\nNOTE: %s", button.name, tostring(button.editNote))
            local value = device.showInputBox("Change object property", message, tostring(button.value))
            if value ~= "" then
                updateObject(function()
                    button.editFunction(self.object_, value)
                end)
            end
        end
    end
end

function ObjectInspector:getView()
    return self.sprite_
end

function ObjectInspector:createView(parent, object)
    local layer = display.newNode()
    local bg = display.newSprite("#EditorPanelBg.png")
    local size = bg:getContentSize()
    bg:align(display.LEFT_TOP, 0, 0)
    bg:getTexture():setAliasTexParameters()
    layer:addChild(bg)
    layer:setVisible(false)
    parent:addChild(layer)

    local closeButton = display.newSprite("#EditorPanelCloseButton.png")
    local offset = EditorConstants.PANEL_BUTTON_SIZE / 2 + EditorConstants.PANEL_BUTTON_OFFSET
    closeButton:setPosition(offset, -offset)
    layer:addChild(closeButton)

    self.positionButton_ = display.newSprite("#EditorPanelPositionButton.png")
    self.positionButton_:setPosition(0, -offset)
    layer:addChild(self.positionButton_)

    self.bg_ = bg
    self.sprite_ = layer
    return layer
end

function ObjectInspector:removeView()
    if self.sprite_ then
        self.sprite_:removeSelf()
        self.sprite_ = nil
    end
end

function ObjectInspector:setPosition()
    local width, height = unpack(self.size_)

    local size = self.bg_:getContentSize()
    self.bg_:setScaleX(width / size.width)
    self.bg_:setScaleY(height / size.height)

    local offset = EditorConstants.PANEL_OFFSET

    if self.position_ == ObjectInspector.POSITION_LEFT_TOP then
        self.sprite_:align(display.LEFT_TOP,
                           display.c_left + offset,
                           display.c_top - offset)
    elseif self.position_ == ObjectInspector.POSITION_RIGHT_TOP then
        self.sprite_:align(display.LEFT_TOP,
                           display.c_right - width - offset,
                           display.c_top - offset)
    elseif self.position_ == ObjectInspector.POSITION_LEFT_BOTTOM then
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

function ObjectInspector:setObject(object)
    local isVisible = self.isVisible_
    local changeVisible = self.object_ ~= object
    if self.panel_ then self:removeObject() end
    if not changeVisible then
        self.isVisible_ = isVisible
    end

    local panel = display.newNode()
    self.sprite_:addChild(panel)
    self.panel_ = panel

    -- add properties label
    local lines = {}
    lines[#lines + 1] = {
        name  = "Id",
        value = object:getId(),
    }
    lines[#lines + 1] = {
        name  = "defineId",
        value = object:getDefineId(),
    }

    -- if object.behaviors_ and table.nums(object.behaviors_) > 0 then
    --     lines[#lines + 1] = {"behaviors", table.concat(table.keys(object.behaviors_), ", ")}
    -- end

    lines[#lines + 1] = {
        name  = "radius",
        value = format("%0.2f", object:getRadius()),
        -- edit  = true,
        -- editNote = "radius is integer",
        -- editFunction = function(object, newvalue)
        --     object.radius_ = toint(newvalue)
        -- end
    }

    lines[#lines + 1] = {
        name  = "initVisible",
        value = format("%s", tostring(object:isInitVisible())),
        edit  = true,
        editNote = "\"true, yes, 1\" = true, others = false",
        editFunction = function(object, newvalue)
            newvalue = string.lower(tostring(newvalue))
            if newvalue == "1" or newvalue == "true" or newvalue == "yes" then
                newvalue = true
            else
                newvalue = false
            end
            object:setInitVisible(newvalue)
        end
    }

    lines[#lines + 1] = {
        name  = "flipSprite",
        value = format("%s", tostring(object:isFlipSprite())),
        edit  = true,
        editNote = "\"true, yes, 1\" = true, others = false",
        editFunction = function(object, newvalue)
            newvalue = string.lower(tostring(newvalue))
            if newvalue == "1" or newvalue == "true" or newvalue == "yes" then
                newvalue = true
            else
                newvalue = false
            end
            object:setFlipSprite(newvalue)
        end
    }

    if object:hasBehavior("CollisionBehavior") then
        lines[#lines + 1] = {
            name  = "collisionEnabled",
            value = format("%s", tostring(object:isCollisionEnabled())),
            edit  = true,
            editNote = "\"true, yes, 1\" = true, others = false",
            editFunction = function(object, newvalue)
                newvalue = string.lower(tostring(newvalue))
                if newvalue == "1" or newvalue == "true" or newvalue == "yes" then
                    newvalue = true
                else
                    newvalue = false
                end
                object:setCollisionEnabled(newvalue)
            end
        }
    end

    if object:hasBehavior("NPCBehavior") then
        lines[#lines + 1] = {
            name  = "npcId",
            value = object:getNPCId(),
            edit  = true,
            editNote = "npcId is string",
            editFunction = function(object, newvalue)
                object:setNPCId(newvalue)
            end
        }
    end

    if object:hasBehavior("TowerBehavior") then
        lines[#lines + 1] = {
            name  = "towerId",
            value = object:getTowerId(),
            edit  = true,
            editNote = "towerId is string",
            editFunction = function(object, newvalue)
                object:setTowerId(newvalue)
            end
        }
    end

    if object:hasBehavior("PlayerBehavior") then
        lines[#lines + 1] = {
            name  = "playerTestId",
            value = object:getPlayerTestId(),
            edit  = true,
            editNote = "playerTestId is string",
            editFunction = function(object, newvalue)
                object:setPlayerTestId(newvalue)
            end
        }
    end

    if object:hasBehavior("BuildingBehavior") then
        lines[#lines + 1] = {
            name  = "buildingId",
            value = object:getBuildingId(),
            edit  = true,
            editNote = "buildingId is string",
            editFunction = function(object, newvalue)
                object:setBuildingId(newvalue)
            end
        }
    end

    if object:hasBehavior("FireBehavior") then
        lines[#lines + 1] = {
            name  = "fireRange",
            value = object:getFireRange(),
            -- edit  = true,
            -- editNote = "fireRange is integer",
            -- editFunction = function(object, newvalue)
            --     object.fireRange_ = toint(newvalue)
            -- end
        }
    end

    if object:hasBehavior("DecorateBehavior") then
        local v = object.decorationsMore_
        if v then
            v = table.concat(table.keys(v), ",")
        else
            v = ""
        end
        lines[#lines + 1] = {
            name  = "decorationsMore",
            value = v,
            edit  = true,
            editNote = "decorationsMore is string",
            editFunction = function(object, newvalue)
                newvalue = string.split(newvalue, ",")
                object.decorationsMore_ = {}
                for i, name in ipairs(newvalue) do
                    object.decorationsMore_[name] = false
                end
            end
        }
    end

    lines[#lines + 1] = {
        name  = "x, y",
        value = format("%0.2f, %0.2f", object:getPosition()),
        edit  = true,
        editNote = "position format is x, y",
        editFunction = function(object, newvalue)
            newvalue = string.split(newvalue, ",")
            if #newvalue == 2 then
                local x = toint(string.trim(newvalue[1]))
                local y = toint(string.trim(newvalue[2]))
                object:setPosition(x, y)
            end
        end
    }

    if object:hasBehavior("CampBehavior") then
        lines[#lines + 1] = {
            name  = "campId",
            value = object:getCampId(),
            edit  = true,
            editNote = "campId is integer",
            editFunction = function(object, newvalue)
                object.campId_ = toint(newvalue)
            end
        }
    end

    if object:hasBehavior("DestroyedBehavior") then
        lines[#lines + 1] = {
            name  = "maxHp",
            value = object:getMaxHp(),
            -- edit  = true,
            -- editNote = "maxHp is integer",
            -- editFunction = function(object, newvalue)
            --     object.maxHp_ = toint(newvalue)
            -- end
        }
    end

    if object:hasBehavior("UpgradableBehavior") then
        lines[#lines + 1] = {
            name  = "maxLevel",
            value = object:getMaxLevel(),
        }
        lines[#lines + 1] = {
            name  = "level",
            value = object:getLevel(),
            edit  = true,
            editNote = format("level is integer, max = %s", tostring(object:getMaxLevel())),
            editFunction = function(object, newvalue)
                newvalue = toint(newvalue)
                if newvalue < 1 then
                    newvalue = 1
                elseif newvalue > object:getMaxLevel() then
                    newvalue = object:getMaxLevel()
                end
                object:setLevel(newvalue)
            end
        }
    end

    if object:hasBehavior("MovableBehavior") then
        lines[#lines + 1] = {
            name  = "bindingPathId",
            value = object:getBindingPathId(),
        }
        lines[#lines + 1] = {
            name  = "bindingPointIndex",
            value = tostring(object:getBindingPointIndex()),
        }
        lines[#lines + 1] = {
            name  = "bindingMovingForward",
            value = tostring(object:isMovingForward()),
            edit  = true,
            editNote = "\"true, yes, 1\" = true, others = false",
            editFunction = function(object, newvalue)
                newvalue = string.lower(tostring(newvalue))
                if newvalue == "1" or newvalue == "true" or newvalue == "yes" then
                    newvalue = true
                else
                    newvalue = false
                end
                object:setMovingForward(newvalue)
            end
        }
    end

    self.editButtons_ = {}
    local maxWidth = 0
    local labelX = 26
    local labelY = -14
    for i, pair in ipairs(lines) do
        local prefix = string.rep(" ", EditorConstants.PROPERTY_PREFIX_LEN - string.len(pair.name)) .. pair.name
        local text   = format("%s = %s", tostring(prefix), tostring(pair.value))
        local label  = ui.newTTFLabel({
            text  = text,
            font  = EditorConstants.PANEL_LABEL_FONT,
            size  = EditorConstants.PANEL_LABEL_FONT_SIZE,
            align = ui.TEXT_ALIGN_LEFT,
            x     = labelX,
            y     = labelY,
        })
        panel:addChild(label)

        if pair.edit then
            local editButton = display.newSprite("#EditButton.png", labelX - 10, labelY)
            panel:addChild(editButton)
            pair.x, pair.y = labelX - 10, labelY
            self.editButtons_[#self.editButtons_ + 1] = pair
        end

        labelY = labelY - EditorConstants.PANEL_LABEL_FONT_SIZE - 3
        local size = label:getContentSize()
        if size.width > maxWidth then
            maxWidth = size.width
        end
    end

    local panelWidth  = maxWidth + 30
    if panelWidth < EditorConstants.INSPECTOR_WIDTH then
        panelWidth = EditorConstants.INSPECTOR_WIDTH
    end

    -- labelY = labelY
    local allStaticObjectBehaviorsName = BehaviorFactory.getAllStaticObjectBehaviorsName()
    local numCols = math.floor(panelWidth / EditorConstants.BEHAVIOR_LABEL_WIDTH)
    local numRows = math.ceil(#allStaticObjectBehaviorsName / numCols)
    local panelHeight = -labelY + 54 + (numRows - 1) * 26
    local column = 0
    labelY = labelY - 20
    self.behaviorsLabel_ = {}
    for i, behavior in ipairs(allStaticObjectBehaviorsName) do
        local sprite = display.newSprite("#BehaviorLabelBackground.png")
        local size = sprite:getContentSize()

        local text = ui.newTTFLabel({
            text = string.upper(string.sub(behavior, 1, -9)),
            size = 11,
            align = ui.TEXT_ALIGN_LEFT,
            x = 20,
            y = 16,
        })
        sprite:addChild(text)
        local label = {
            x        = labelX + EditorConstants.BEHAVIOR_LABEL_WIDTH * column,
            y        = labelY,
            width    = size.width,
            height   = size.height,
            isLocked = false,
        }
        sprite:align(display.LEFT_TOP, label.x, label.y)
        sprite:pixels()

        label.sprite = sprite
        self.behaviorsLabel_[i] = label

        if not object:hasBehavior(behavior) then
            sprite:setOpacity(80)
        else
            local selected = display.newSprite("#BehaviorLabelSelected.png")
            selected:align(display.LEFT_BOTTOM, 0, 0)
            sprite:addChild(selected)
        end

        if object.behaviorDepends_ and object.behaviorDepends_[behavior] then
            label.isLocked = true
            local lock = display.newSprite("#BehaviorLabelLocked.png")
            lock:align(display.LEFT_BOTTOM, 0, 0)
            sprite:addChild(lock)
        end

        panel:addChild(sprite)

        column = column + 1
        if column == numCols then
            column = 0
            labelY = labelY - 26
        end
    end

    self.object_ = object
    self.size_ = {panelWidth, panelHeight}
    self:setPosition()
    self.sprite_:setVisible(self.isVisible_)
end

function ObjectInspector:removeObject()
    if self.panel_ then
        self.sprite_:setVisible(false)
        self.panel_:removeSelf()
        self.panel_ = nil
        self.object_ = nil
        self.isVisible_ = true
    end
end

return ObjectInspector

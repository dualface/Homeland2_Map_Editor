
local math2d = require("math2d")
local PathRunner = class("PathRunner")

PathRunner.ROTATION_DEFAULT_STEPS = 10

function PathRunner:ctor(speed, beingPointIndex, isForward, maxMovingLen)
    self.speed_        = speed
    self.sprite_       = nil
    self.index_        = toint(beingPointIndex)
    self.isForward_    = isForward
    self.len_          = -1
    self.movingLen_    = 0
    self.maxMovingLen_ = maxMovingLen or 0
    self.offset_       = {}

    if type(self.isForward_) ~= "boolean" then
        self.isForward_ = true
    end

    if self.index_ ~= 0 then
        if self.isForward_ then
            self.index_ = self.index_ - 1
        else
            self.index_ = self.index_ + 1
        end
    end

    self.destRotation_       = 0
    self.rotationSteps_      = PathRunner.ROTATION_DEFAULT_STEPS
    self.rotationOffset_     = nil
    self.rotationOffsetStep_ = 0
end

function PathRunner:createView(parent, imgname)
    self.sprite_ = display.newSprite(imgname)
    parent:addChild(self.sprite_)
end

function PathRunner:removeView()
    self.sprite_:removeSelf()
end

function PathRunner:getMovingLen()
    return self.movingLen_
end

function PathRunner:setRotationOffsetSteps(steps)
    self.rotationSteps_ = steps
end

function PathRunner:setNextPoint(pointsCount, functionGetPoint)
    local nextPointIndex
    if self.isForward_ then
        self.index_ = self.index_ + 1
        nextPointIndex = self.index_ + 1
    else
        self.index_ = self.index_ - 1
        nextPointIndex = self.index_ - 1
    end

    if nextPointIndex > pointsCount or nextPointIndex < 1 then
        return false
    end

    local ax, ay  = functionGetPoint(self.index_)
    local bx, by  = functionGetPoint(nextPointIndex)
    local radians = math2d.radians4point(ax, ay, bx, by)
    local ox, oy  = math2d.pointAtCircle(0, 0, radians, self.speed_)
    self.len_     = math2d.dist(ax, ay, bx, by)
    self.offset_  = {ox, oy}
    self.sprite_:setPosition(ax, ay)
    self.destRotation_ = math2d.radians2degrees(radians)

    if self.rotationOffset_ == nil or self.rotationSteps_ < 1 then
        self.sprite_:setRotation(self.destRotation_)
        self.rotationOffset_ = 0
        self.rotationOffsetStep_ = 0
    else
        local rotation = self.sprite_:getRotation()
        self.rotationOffset_ = (self.destRotation_ - rotation) / self.rotationSteps_
        self.rotationOffsetStep_ = self.rotationSteps_
    end

    return true
end

function PathRunner:tick(dt, pointsCount, functionGetPoint)
    if self.len_ < 0 then
        if not self:setNextPoint(pointsCount, functionGetPoint) then
            return false
        end
    end

    local x, y = self.sprite_:getPosition()
    x = x + self.offset_[1]
    y = y + self.offset_[2]
    self.len_ = self.len_ - self.speed_
    self.movingLen_ = self.movingLen_ + self.speed_
    self.sprite_:setPosition(x, y)
    if self.rotationOffsetStep_ > 0 then
        self.rotationOffsetStep_ = self.rotationOffsetStep_ - 1
        local rotation = self.sprite_:getRotation()
        rotation = rotation + self.rotationOffset_
        self.sprite_:setRotation(rotation)
    end

    if self.maxMovingLen_ > 0 then
        if self.movingLen_ >= self.maxMovingLen_ then
            return false
        end

        local r = self.movingLen_ / self.maxMovingLen_
        local o = 255
        if r < 0.3 then
            o = 255 * (r / 0.3)
        elseif r > 0.8 then
            o = 255 * ((1.0 - r) / 0.2)
        end
        self.sprite_:setOpacity(o)
    end

    return true
end

return PathRunner

require("code.utilities.extended_math")
local Player = {x = 0, y = 0, index = 1, animation = {}}
local lastbutton = "none"

function getAxisValueDigital(joystick)
    local value = {x=0,y=0}
    local leftIsDown, rightIsDown = false, false
    local upIsDown, downIsDown = false, false

    --Get keyboard or dpad input
    if joystick == nil then
        leftIsDown = love.keyboard.isDown("left") or love.keyboard.isDown("a")
        rightIsDown = love.keyboard.isDown("right") or love.keyboard.isDown("d")
        upIsDown = love.keyboard.isDown("up") or love.keyboard.isDown("w")
        downIsDown = love.keyboard.isDown("down") or love.keyboard.isDown("s")
    else
        leftIsDown = joystick:isGamepadDown("dpleft")
        rightIsDown = joystick:isGamepadDown("dpright")
        upIsDown = joystick:isGamepadDown("dpup")
        downIsDown = joystick:isGamepadDown("dpdown")
    end

    if rightIsDown then
        value.x = value.x + 1
    end
    if leftIsDown then
        value.x = value.x - 1
    end
    if upIsDown then
        value.y = value.y - 1
    end
    if downIsDown then
        value.y = value.y + 1
    end

    return value
end

function Player:getInput()
    local joysticks = love.joystick.getJoysticks()
    self.input = {x = 0, y = 0}
    if #joysticks > 1 then
        self.input = getAxisValueDigital(joysticks[self.index])
        -- self.input.x = joysticks[self.index]:getGamepadAxis("leftx")
        -- self.input.y = joysticks[self.index]:getGamepadAxis("lefty")
    else
        if self.index == 1 then
            self.input = getAxisValueDigital()
        elseif #joysticks == 1 then
            self.input = getAxisValueDigital(joysticks[1])
            -- self.input.x = joysticks[1]:isGamepadDown("leftx")
            -- self.input.y = joysticks[1]:isGamepadDown("lefty")
        end
    end
    self.input.x, self.input.y = math.normalize(self.input.x, self.input.y)
end

function Player:update(dt)
    --Update animation
    self.animation.currentTime = self.animation.currentTime + dt
    if self.animation.currentTime >= self.animation.duration then
        self.animation.currentTime = self.animation.currentTime - self.animation.duration
    end

    --Move player
    self:getInput()
    self.x = self.x + self.input.x
    self.y = self.y + self.input.y
end

function Player:draw()
    local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
    love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], self.x, self.y)
end

function Player:create(x, y, index, animation)
    self.__index = self
    return setmetatable({
        x = x,
        y = y,
        index = index,
        input = {},
        animation = animation
    }, self)
end

return Player
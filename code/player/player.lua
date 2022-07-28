local Player = {x = 0, y = 0, index = 1, animation = {}, box = {}, color = {1,1,1,1}}
local Input = require("code.player.player_input")

function Player:update(dt)
    --Update animation
    self.animation.currentTime = self.animation.currentTime + dt
    if self.animation.currentTime >= self.animation.duration then
        self.animation.currentTime = self.animation.currentTime - self.animation.duration
    end
    --Move player
    self.input = Input:get_input(self.index)

    self.x = self.x + self.input.x
    self.y = self.y + self.input.y
    self.box.x = self.x
    self.box.y = self.y
end

function Player:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("line", self.box.x, self.box.y, self.box.w, self.box.h)
    local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
    love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], self.x, self.y)
end

function Player:create(x, y, index, animation, box)
    self.__index = self
    return setmetatable({
        x = x,
        y = y,
        index = index,
        input = {},
        animation = animation,
        box = box,
        color = {1,1,1,1}
    }, self)
end

return Player
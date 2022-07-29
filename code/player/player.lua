Player = {}
require("code.player.player_drawing")

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

function Player:create(x, y, index, animation, box)
    self.__index = self
    local obj = setmetatable({
        x = x,
        y = y,
        index = index,
        input = {},
        animation = animation,
        box = box,
        color = {1,1,1,1}
    }, self)
    
    return obj
end

return Player
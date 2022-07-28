function Player:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("line", self.box.x, self.box.y, self.box.w, self.box.h)
    local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
    love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], self.x, self.y)
end
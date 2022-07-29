function Player:draw()
  love.graphics.setColor(self.color)
  local sprite_index = math.floor(self.current_animation.current_time / self.current_animation.duration * #self.current_animation.quads) + 1
  love.graphics.draw(self.current_animation.sprite_sheet, self.current_animation.quads[sprite_index], self.box.x, self.box.y)
end

function Player:draw_bounding_box()
  love.graphics.rectangle("line", self.box.x, self.box.y, self.box.w, self.box.h)
end

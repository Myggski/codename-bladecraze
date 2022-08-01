local camera = {
  visual_resolution_x = 256,
  visual_resolution_y = 144,
  translate_position_x = 0,
  translate_position_y = 0,
}

function camera:get_scale()
  return {
    x = love.graphics.getWidth() / self.visual_resolution_x,
    y = love.graphics.getHeight() / self.visual_resolution_y,
  }
end

function camera:get_translate()
  return {
    x = self.translate_position_x,
    y = self.translate_position_y,
  }
end

return camera

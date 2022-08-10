local camera = {
  --[[
    resolution can be changed to
    GAME_WIDTH and GAME_HEIGHT globals
    ]]
  visual_resolution_x = 256,
  visual_resolution_y = 144,
  translate_position_x = 0,
  translate_position_y = 0,
}

function camera:get_scale()
  return love.graphics.getWidth() / self.visual_resolution_x, love.graphics.getHeight() / self.visual_resolution_y
end

function camera:get_translate()
  return self.translate_position_x, self.translate_position_y
end

function camera:screen_to_world(screen_x, screen_y)
  local scale_x, scale_y = self:get_scale()
  return screen_x / scale_x, screen_y / scale_y
end

return camera

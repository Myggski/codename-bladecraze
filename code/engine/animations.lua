
local animations = {}

function animations.newAnimation(image, image_data, duration)
  local offset_x, offset_y, width, height, frame_count = unpack(image_data)
  local animation = {}
  animation.quads = {};
  animation.sprite_sheet = image;
  animation.duration = duration
  animation.current_time = 0

  local i = 0;
  for y = offset_y, image:getHeight() - height, height do
      for x = offset_x, image:getWidth() - width, width do
          table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
          i = i + 1
          if (i >= frame_count) then
              return animation
          end
      end
  end
  return animation
end

return animations

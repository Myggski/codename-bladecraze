local animations = {}

function animations.new_animation(image, image_data, duration)
  local offset_x, offset_y, width, height, frame_count = unpack(image_data)
  local animation = {
    quads = {},
    texture = image,
    duration = duration,
    current_time = 0,
    current_quad = {},
    viewport = { x = 0, y = 0 },
  }

  local frames_added = 0;
  for y = offset_y, image:getHeight() - height, height do
    for x = offset_x, image:getWidth() - width, width do
      table.insert(
        animation.quads,
        love.graphics.newQuad(x, y, width, height, image)
      )

      frames_added = frames_added + 1
      if frames_added >= frame_count then goto continue end
    end
  end

  ::continue::
  animation.current_quad = animation.quads[1]
  _, _, animation.viewport.x, animation.viewport.y = animation.current_quad:getViewport()
  return animation
end

return animations

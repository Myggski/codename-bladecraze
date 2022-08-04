local function draw_player(player)
  -- texture, quad, x, y, r, sx, sy, ox, oy, kx, ky
  love.graphics.setColor(player.color)

  local current_animation = player.animations.current

  local sprite_index = math.floor(current_animation.current_time / current_animation.duration *
    #current_animation.quads) + 1

  local quad = current_animation.quads[sprite_index]
  local _,_,w,h = quad:getViewport()
  local origin_x, origin_y = w/2, h/2
  love.graphics.draw(
    current_animation.sprite_sheet,
    quad, player.center_position.x,
    player.center_position.y, 0, player.direction, 1, origin_x, origin_y
  )
end

local function draw_player_bounding_box(player)
  love.graphics.setColor(1,0,0,1)
  love.graphics.rectangle("line", player.box.x, player.box.y, player.box.w, player.box.h)
end

local function draw_text(x, y, text)
  local angle, scale_x, scale_y, offset_x, offset_y, skew_x, skew_y = 0, 0.5, 0.5, 0, 0, 0, 0

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(text, x, y, angle, scale_x,
    scale_y, offset_x, offset_y, skew_x, skew_y)
end

local function update_animation(animation, dt)
  animation.current_time = animation.current_time + dt

  if animation.current_time > animation.duration then
    animation.current_time = animation.current_time - animation.duration
  end

  animation.current_time = animation.current_time
  return animation
end

return {
  draw_text = draw_text,
  draw_player = draw_player,
  draw_player_bounding_box = draw_player_bounding_box,
  update_animation = update_animation
}

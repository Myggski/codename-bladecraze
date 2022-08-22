local asset_manager = require("code.engine.asset_manager")

local font = nil
local function draw_player(player)
  love.graphics.setColor(player.color)

  local current_animation = player.animations.current

  local sprite_index = math.floor(current_animation.current_time / current_animation.duration *
    #current_animation.quads) + 1

  local quad = current_animation.quads[sprite_index]
  local _, _, w, h = quad:getViewport()
  local origin_x, origin_y = w / 2, h / 2
  love.graphics.draw(
    current_animation.sprite_sheet,
    quad,
    player.box:center_x(),
    player.box:center_y(),
    0,
    player.direction,
    1,
    origin_x,
    origin_y
  )
end

local function draw_player_bounding_box(player)
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.rectangle("line", player.box.x, player.box.y, player.box.w, player.box.h)
  love.graphics.setColor(1, 1, 1, 1)
end

local function draw_text(x, y, text)
  local angle, scale_x, scale_y, offset_x, offset_y, skew_x, skew_y = 0, 0.5, 0.5, 0, 0, 0, 0
  font = font or asset_manager:get_font("Silver.ttf", 32, "normal")
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(text, font, x, y, angle, scale_x,
    scale_y, offset_x, offset_y, skew_x, skew_y)
end

local function draw_stats(player)
  local str = ""
  for key, value in pairs(player.stats) do
    str = str .. key .. ":" .. value .. "\n"
  end

  -- draw_text(player.box.x, player.box.y + 20, str)
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
  draw_stats = draw_stats,
  draw_player = draw_player,
  draw_player_bounding_box = draw_player_bounding_box,
  update_animation = update_animation
}

local asset_manager = require "code.engine.asset_manager"
local camera = require "code.engine.camera"
local world_grid = require "code.engine.world_grid"

local font = nil
local function draw_player(player)
  local current_animation = player.animations.current
  local sprite_index = math.floor(current_animation.current_time / current_animation.duration *
    #current_animation.quads) + 1
  local quad = current_animation.quads[sprite_index]
  local _, _, w, h = quad:getViewport()
  local origin_x, origin_y = w * 0.5, h * 0.5
  love.graphics.draw(
    current_animation.sprite_sheet,
    quad,
    world_grid:convert_to_world(player.box:center_x()),
    world_grid:convert_to_world(player.box:center_y()),
    0,
    player.direction,
    1,
    origin_x,
    origin_y
  )
end

local function draw_player_bounding_box(player)
  local x, y, w, h = world_grid:convert_to_world(player.box.x),
      world_grid:convert_to_world(player.box.y),
      world_grid:convert_to_world(player.box.w),
      world_grid:convert_to_world(player.box.h)

  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.rectangle("line", x, y, w, h)
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
end

local function update_animation(animation, dt)
  animation.current_time = animation.current_time + dt

  if animation.current_time > animation.duration then
    animation.current_time = 0
  end

  return animation
end

return {
  draw_text = draw_text,
  draw_stats = draw_stats,
  draw_player = draw_player,
  draw_player_bounding_box = draw_player_bounding_box,
  update_animation = update_animation
}

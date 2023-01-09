local camera = require "code.engine.camera"
local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local world_grid = require "code.engine.world_grid"

local camera_filter = entity_query.filter(function(e)
  return camera:is_outside_camera_view(e[components.position], e[components.size]) and e:is_alive()
end)

local draw_query = entity_query
    .all(components.position, components.size)
    .any(components.animation, components.sprite)
    .none(camera_filter())

local binary_insert = table.binary_insert
local binary_search = table.binary_search
local draw = love.graphics.draw

local y_segment = 10000 --avoid conflicts between z indices and y positions
local z_offset = 4999

local entity_draw = system(draw_query, function(self)
  local animation, position, size, sprite, current_animation, sort_value, component
  local render_order_array, entity_array = {}, {}
  local game_width = GAME.GAME_WIDTH
  local game_half_width = game_width / 2
  self:for_each(function(entity)
    animation = entity[components.animation]
    position = entity[components.position]
    sprite = entity[components.sprite]
    size = entity[components.size]

    component = animation or sprite
    local z = component.z_index or 0
    local y = math.round(position.y)
    local x = world_grid:convert_to_world(position.x) + game_half_width --get screen position in range 0:GAME_WIDTH while inside screen
    x = math.clamp01(x / game_width) --safety clamp, not needed if object is culled outside screen
    --[[
      x is stored in decimal points
      z is stored in the first 4 integer digits
      y is stored in the 5 digit and greater
      ]]
    sort_value = x + y * y_segment + z + z_offset

    if binary_search(render_order_array, sort_value, 1, #render_order_array) > -1 then
      goto continue
    end

    binary_insert(render_order_array, sort_value)
    entity_array[sort_value] = entity

    ::continue::
  end)
  local entity, shader
  for i = 1, #render_order_array do
    entity = entity_array[render_order_array[i]]
    animation = entity[components.animation]
    position = entity[components.position]
    size = entity[components.size]
    sprite = entity[components.sprite]
    shader = entity[components.shader]
    if shader then
      love.graphics.setShader(shader)
    end

    if animation then
      current_animation = animation[animation.current_animation_state]
      draw(
        current_animation.texture,
        current_animation.current_quad,
        world_grid:convert_to_world(position.x + size.x * 0.5),
        world_grid:convert_to_world(position.y + size.y * 0.5),
        0,
        animation.direction,
        1,
        current_animation.viewport.x * 0.5,
        current_animation.viewport.y * 0.5
      )
    elseif sprite then
      draw(
        sprite.texture,
        world_grid:convert_to_world(position.x + size.x * 0.5),
        world_grid:convert_to_world(position.y + size.y * 0.5)
      )
    end

    if shader then
      love.graphics.setShader()
    end
  end
end)

return entity_draw

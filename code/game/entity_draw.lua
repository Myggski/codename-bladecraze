local camera = require "code.engine.camera"
local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local world_grid = require "code.engine.world_grid"
local debug = require "code.engine.debug"

local camera_filter = entity_query.filter(function(e)
  return camera:is_outside_camera_view(e[components.position], e[components.size])
end)

local draw_query = entity_query
    .all(components.position, components.size)
    .any(components.animation, components.sprite)
    .none(camera_filter())

local z_index_range = 100
local x_range = 13
local render_group_range = z_index_range + x_range

local binary_insert = table.binary_insert
local binary_search = table.binary_search
local draw = love.graphics.draw

local entity_draw = system(draw_query, function(self)
  local animation, position, size, sprite, current_animation = nil, nil, nil, nil, nil
  local render_order_array = {}, entity_array = {}

  self:for_each(function(entity)
    animation = entity[components.animation]
    position = entity[components.position]
    sprite = entity[components.sprite]
    size = entity[components.size]

    local component = animation or sprite
    local z_index = component.z_index
    local sort_value = position.y * render_group_range + position.x + z_index

    if binary_search(render_order_array, sort_value, 1, #render_order_array) > -1 then
      goto continue
    end

    binary_insert(render_order_array, sort_value)
    entity_array[sort_value] = entity

    ::continue::

  end)

  for i = 1, #render_order_array do
    local entity = entity_array[render_order_array[i]]
    animation = entity[components.animation]
    position = entity[components.position]
    size = entity[components.size]
    sprite = entity[components.sprite]
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
  end
end)

return entity_draw

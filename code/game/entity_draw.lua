local camera = require "code.engine.camera"
local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local world_grid = require "code.engine.world_grid"

local camera_filter = entity_query.filter(function(e)
  return camera:is_outside_camera_view(e[components.position], e[components.size])
end)

local draw_query = entity_query
    .all(components.position, components.size)
    .any(components.animation, components.sprite)
    .none(camera_filter())

local entity_draw = system(draw_query, function(self)
  local animation, position, size, sprite, current_animation = nil, nil, nil, nil, nil

  self:for_each(function(entity)
    animation = entity[components.animation]
    position = entity[components.position]
    size = entity[components.size]
    sprite = entity[components.sprite]

    if animation then
      current_animation = animation[animation.current_animation_state]

      love.graphics.draw(
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
      love.graphics.draw(
        sprite.texture,
        world_grid:convert_to_world(position.x + size.x * 0.5),
        world_grid:convert_to_world(position.y + size.y * 0.5)
      )
    end
  end)
end)

return entity_draw

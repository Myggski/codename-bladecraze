local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"
local camera = require "code.engine.camera"
local world_grid = require "code.engine.world_grid"

local camera_filter = entity_query.filter(function(e)
  return camera:is_outside_camera_view(e[components.position], e[components.size])
end)
local draw_query = entity_query
    .all(components.position, components.size)
    .any(components.animation, components.sprite)
    .none(camera_filter())

local entity_draw = system(draw_query, function(self)
  local animation, position, size, sprite, current_animation, sprite_index = nil, nil, nil, nil, nil, nil
  local quad, center_position, w, h = nil, { x = 0, y = 0 }, 0, 0

  self:for_each(draw_query, function(entity)
    animation = entity[components.animation]
    position = entity[components.position]
    size = entity[components.size]
    sprite = entity[components.sprite]

    center_position = get_center_position(position, size)

    if animation then
      current_animation = animation[animation.current_animation_state]
      sprite_index = 1 +
          math.floor(current_animation.current_time / current_animation.duration * #current_animation.quads)
      quad = current_animation.quads[sprite_index]
      _, _, w, h = quad:getViewport()

      love.graphics.draw(
        current_animation.sprite_sheet,
        quad,
        world_grid:convert_to_world(center_position.x),
        world_grid:convert_to_world(center_position.y),
        0,
        animation.direction,
        1,
        w * 0.5,
        h * 0.5
      )
    elseif sprite then
      love.graphics.draw(
        sprite,
        world_grid:convert_to_world(center_position.x),
        world_grid:convert_to_world(center_position.y)
      )
    end
  end)
end)

return entity_draw

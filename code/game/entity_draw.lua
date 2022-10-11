local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"
local player_drawing = require "code.player.player_drawing"
local world_grid = require "code.engine.world_grid"

local draw_query = entity_query.all(components.position, components.size).any(components.animation, components.sprite)

local entity_draw = system(draw_query, function(self)
  local animation, position, size, current_animation, sprite_index, quad = nil, nil, nil, nil, nil, nil
  local w, h, origin_x, origin_y, center_position = nil, nil, nil, nil, { x = 0, y = 0 }

  for _, entity in self:entity_iterator() do
    animation = entity[components.animation]
    position = entity[components.position]
    size = entity[components.size]

    current_animation = animation[animation.current_animation_state]
    sprite_index = math.floor(current_animation.current_time / current_animation.duration *
      #current_animation.quads) + 1
    quad = current_animation.quads[sprite_index]
    center_position = get_center_position(position, size)
    _, _, w, h = quad:getViewport()
    origin_x, origin_y = w / 2, h / 2

    love.graphics.draw(
      current_animation.sprite_sheet,
      quad,
      world_grid:convert_to_world(center_position.x),
      world_grid:convert_to_world(center_position.y),
      0,
      animation.direction,
      1,
      origin_x,
      origin_y
    )
  end
end)

return entity_draw

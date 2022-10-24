local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local utilities = require "code.engine.utilities"
local world_grid = require "code.engine.world_grid"
local gizmos = require "code.engine.debug.gizmos"

local block_filter = entity_query.filter(function(e)
  return e[components.block] == true
end)
local block_query = entity_query.all(components.position, components.size, components.block, block_filter())

local block_system = system(block_query, function(self, dt)
  local position, size, nearby_entites, nearby_position, nearby_size = nil, nil, nil, nil, nil
  local dir_x, dir_y, dist = 0, 0, 0

  self:for_each(function(entity)
    position = entity[components.position]
    size = entity[components.size]

    nearby_entites = self:find_near_entities(position, size * 3.25, set.create { entity })

    for nearby_entity, _ in pairs(nearby_entites) do
      nearby_position, nearby_size = nearby_entity[components.position], nearby_entity[components.size]

      local center_a = utilities.get_center_position(position, size)
      local center_b = utilities.get_center_position(nearby_position, nearby_size)

      gizmos.draw_line({
        world_grid:convert_to_world(center_a.x), world_grid:convert_to_world(center_a.y),
        world_grid:convert_to_world(center_b.x), world_grid:convert_to_world(center_b.y)
      })

      gizmos.draw_rectangle(position * 16, size * 16)
      gizmos.draw_rectangle(nearby_position * 16, nearby_size * 16)

      if utilities.overlap(position, size, nearby_position, nearby_size) then
        local collision_direction = utilities.collision_direction(center_a, center_b)

        local is_moving_towards_x = nearby_entity[components.velocity] and
            math.dot(nearby_entity[components.velocity].x, nearby_entity[components.velocity].y, collision_direction.x,
              collision_direction.y) < 0

        local is_moving_towards_y = nearby_entity[components.velocity] and
            math.dot(nearby_entity[components.velocity].x, nearby_entity[components.velocity].y, collision_direction.x,
              collision_direction.y) < 0

        -- Check left/right collision
        if not (collision_direction.x == 0) and is_moving_towards_x then
          local nearby_entity_x = center_b.x + ((nearby_size.x * 0.5) * -collision_direction.x)
          local blocking_entity_x = center_a.x + ((size.x * 0.5) * collision_direction.x)

          nearby_position.x = nearby_position.x - (nearby_entity_x - blocking_entity_x) + (0.001 * collision_direction.x
              )
          nearby_entity[components.velocity].x = 0
        end

        -- Check up/down collision
        if not (collision_direction.y == 0) and is_moving_towards_y then
          local nearby_entity_y = center_b.y + ((nearby_size.y * 0.5) * -collision_direction.y)
          local blocking_entity_y = center_a.y + ((size.y * 0.5) * collision_direction.y)

          nearby_position.y = nearby_position.y - (nearby_entity_y - blocking_entity_y) + (0.001 * collision_direction.y
              )
          nearby_entity[components.velocity].y = 0
        end
      end
    end

    -- Check collision somehow and get them
    -- collided_entites = check_collision(position, size)

    --[[for index = 1, table.get_size(nearby_entites) do
      entity_position = nearby_entites[index][components.position]
      entity_velocity = nearby_entites[index][components.velocity]

      entity_position.x = entity_position.x - world_grid:convert_to_world(entity_velocity.x * dt)
      entity_position.y = entity_position.y - world_grid:convert_to_world(entity_velocity.y * dt)
    end]]
  end)
end)

return block_system

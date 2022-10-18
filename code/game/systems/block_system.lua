local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"
local world_grid = require "code.engine.world_grid"

local block_filter = entity_query.filter(function(e)
  return e[components.block] == true
end)
local block_query = entity_query.all(components.position, components.size, components.block, block_filter())

local block_system = system(block_query, function(self, dt)
  local position, size, collided_entites, entity_position, entity_velocity = nil, nil, nil, nil, nil

  self:for_each(block_query, function(entity)
    position = entity[components.position]
    size = entity[components.size]

    -- Check collision somehow and get them
    -- collided_entites = check_collision(position, size)

    for index = 1, #collided_entites do
      entity_position = collided_entites[index][components.position]
      entity_velocity = collided_entites[index][components.velocity]

      entity_position.x = entity_position.x - world_grid:convert_to_world(entity_velocity.x * dt)
      entity_position.y = entity_position.y - world_grid:convert_to_world(entity_velocity.y * dt)
    end
  end)
end)

return block_system

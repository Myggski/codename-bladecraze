local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"
local world_grid = require "code.engine.world_grid"

local movement_query = entity_query.all(
  components.position, 
  components.velocity
).none(components.target_position)

local movement_system = system(movement_query, function(self, dt)
  local position, velocity = nil, nil

  self:for_each(nil, function(entity)
    position = entity[components.position]
    velocity = entity[components.velocity]

    position.x = position.x + world_grid:convert_to_world(velocity.x * dt)
    position.y = position.y + world_grid:convert_to_world(velocity.y * dt)
  end)
end)

return movement_system

local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"
local world_grid = require "code.engine.world_grid"

local movement_query = entity_query.all(components.position, components.acceleration)

local movement_system = system(movement_query, function(self, dt)
  local position, acceleration = nil, nil

  for _, entity in self:entity_iterator() do
    position = entity[components.position]
    acceleration = entity[components.acceleration]

    position.x = position.x + world_grid:convert_to_world(acceleration.x * dt)
    position.y = position.y + world_grid:convert_to_world(acceleration.y * dt)
  end
end)

return movement_system

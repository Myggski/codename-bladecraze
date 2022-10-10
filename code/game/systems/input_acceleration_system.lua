local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"

local input_query = entity_query.all(components.input, components.acceleration, components.speed)

local input_system = system(input_query, function(self, dt)
  local input, acceleration, speed = nil, nil, nil

  for _, entity in self:entity_iterator() do
    input = entity[components.input]
    acceleration = entity[components.acceleration]
    speed = entity[components.speed]

    acceleration.x = (input.movement_direction.x * speed) * dt
    acceleration.y = (input.movement_direction.y * speed) * dt
  end
end)

return input_system

local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"

local input_velocity_query = entity_query.all(components.input, components.acceleration, components.speed)

local input_velocity_system = system(input_velocity_query, function(self, dt)
  local input, acceleration, velocity = nil, nil, nil

  self:for_each(input_velocity_query, function(entity)
    input = entity[components.input]
    acceleration = entity[components.acceleration]
    velocity = entity[components.velocity]

    velocity.x = velocity.x +
        ((input.movement_direction.x * acceleration.speed) - (velocity.x * acceleration.friction)) * dt
    velocity.y = velocity.y +
        ((input.movement_direction.y * acceleration.speed) - (velocity.y * acceleration.friction)) * dt

    if math.abs(velocity.x) < 0.01 then
      velocity.x = 0
    end

    if math.abs(velocity.y) < 0.01 then
      velocity.y = 0
    end
  end)
end)

return input_velocity_system

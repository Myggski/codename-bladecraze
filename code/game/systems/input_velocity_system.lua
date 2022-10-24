local components = require "code.engine.components"
local player = require "code.game.entities.player"
local system = require "code.engine.ecs.system"

local input_velocity_system = system(nil, function(self, dt)
  local input, acceleration, velocity = nil, nil, nil

  self:for_each(function(entity)
    input = entity[components.input]
    acceleration = entity[components.acceleration]
    velocity = entity[components.velocity]

    velocity = velocity +
        ((input.movement_direction * acceleration.speed) - (velocity:value() * acceleration.friction)) * dt


    if math.abs(velocity.x) < 0.01 then
      velocity.x = 0
    end

    if math.abs(velocity.y) < 0.01 then
      velocity.y = 0
    end
  end, player.get_archetype())
end)

return input_velocity_system

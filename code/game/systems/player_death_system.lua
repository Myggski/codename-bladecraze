local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local audio = require "code.engine.audio"
local vector2 = require "code.engine.vector2"

local player_death_query = entity_query.all(
  components.input,
  components.destroy_timer
)

local player_death_system = system(player_death_query, function(self, dt)
  local input, health, velocity = nil, nil, nil

  self:for_each(function(entity)
    health = entity[components.health]

    if health <= 0 then
      input = entity[components.input]
      velocity = entity[components.velocity]

      if input.enabled then
        audio:play("player_death.wav")
        input.enabled = false
        input.movement_direction = vector2.zero()
      end

      if velocity then
        velocity = vector2.zero()
      end
    end
  end)
end)

return player_death_system

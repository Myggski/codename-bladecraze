local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"

local player_death_query = entity_query.all(
  components.input,
  components.destroy_timer
)

local player_death_system = system(player_death_query, function(self, dt)
  local input, health = nil, nil

  self:for_each(function(entity)
    health = entity[components.health]

    if health <= 0 then
      input = entity[components.input]

      if input.enabled then
        input.enabled = false
      end
    end
  end)
end)

return player_death_system

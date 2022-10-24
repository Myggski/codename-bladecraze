local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"

local input_query = entity_query.all(components.input)

local input_system = system(input_query, function(self)
  local input = nil

  self:for_each(input_query, function(entity)
    input = entity[components.input]

    if input.action == PLAYER.ACTIONS.BASIC then
      -- Try to drop bomb
    end
  end)
end)

return input_system

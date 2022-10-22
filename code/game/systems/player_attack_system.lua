local components = require "code.engine.components"
local player = require "code.game.entities.player"
local system = require "code.engine.ecs.system"

local input_system = system(_, function(self)
  local input = nil

  self:archetype_for_each(player.get_archetype(), function(entity)
    input = entity[components.input]

    if input.action == PLAYER.ACTIONS.BASIC then
      -- Try to drop bomb
    end
  end)
end)

return input_system

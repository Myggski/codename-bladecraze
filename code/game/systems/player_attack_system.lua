local components = require "code.engine.components"
local player = require "code.game.entities.player"
local system = require "code.engine.ecs.system"

local input_system = system(_, function(self)
  local input = nil

  self:for_each(function(entity)
    input = entity[components.input]

    if input.action == PLAYER.ACTIONS.BASIC then
      -- Try to drop bomb
    end
  end, player.get_archetype())
end)

return input_system

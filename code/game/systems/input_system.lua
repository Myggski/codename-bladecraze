local components = require "code.engine.components"
local player = require "code.game.entities.player"
local player_input = require "code.game.player_input"
local system = require "code.engine.ecs.system"

local input_system = system(nil, function(self)
  local input, pi = nil, nil

  self:archetype_for_each(player.get_archetype(), function(entity)
    input = entity[components.input]

    if not input.enabled then
      return
    end

    pi = player_input.get_input(input.player)

    input.movement_direction = pi.move_dir
    input.action = pi.action
  end)
end)

return input_system

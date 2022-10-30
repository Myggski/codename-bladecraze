local components = require "code.engine.components"
local player = require "code.game.entities.player"
local player_input = require "code.game.player_input"
local system = require "code.engine.ecs.system"

local input_system = system(function(self)
  local input, pi = nil, nil

  self:for_each(function(entity)
    input = entity[components.input]

    if not input.enabled then
      return
    end

    pi = player_input.get_input(input.player_id)

    input.movement_direction = pi.move_dir
    input.action = pi.action
  end, player.get_archetype())
end)

return input_system

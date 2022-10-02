local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"
local player_input = require "code.player.player_input"

local input_query = entity_query.all(components.input, components.position, components.size)

local input_system = system(input_query, function(self)
  local input, position, size, center_position, pi = nil, nil, nil, { x = 0, y = 0 }, nil

  for _, entity in self:list() do
    input = entity[components.input]
    position = entity[components.position]
    size = entity[components.size]

    center_position.x = position.x + size.x / 2
    center_position.y = position.y + size.y / 2
    pi = player_input.get_input(input.player, center_position)

    input.movement_direction = pi.move_dir
    input.aim_direction = pi.aim_dir
    input.action = pi.action
  end
end)

return input_system

local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"
local player_input = require "code.player.player_input"

local highlight_controller_query = entity_query:all(components.position, components.size, components.player_data,
  components.animation)

local highlight_controller_system = system(highlight_controller_query, function(self, _)
  local player_data, animation, offset_x, active_controller, available_controller = nil, nil, nil, nil, nil

  for _, entity in self:entity_iterator() do
    animation = entity[components.animation]
    player_data = entity[components.player_data]

    if (player_input.get_active_controllers())[player_data.player_id] then
      active_controller = (player_input.get_active_controllers())[player_data.player_id]
      player_data.controller_type = active_controller.type

      animation[animation.current_animation_state].current_time = (player_data.player_id +
          (5 * player_data.controller_type)) / 10
    else
      animation[animation.current_animation_state].current_time =
      (5 * player_data.controller_type) / 10
    end
  end
end)

return highlight_controller_system

local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"
local player_drawing = require "code.player.player_drawing"

local animate_query = entity_query.all(components.animation, components.acceleration)

local animation_set_state_system = system(animate_query, function(self, dt)
  local animation, acceleration, current_animation = nil, nil, nil

  for _, entity in self:entity_iterator() do
    animation = entity[components.animation]
    acceleration = entity[components.acceleration]

    -- Default animation - Idling
    current_animation = animation[animation.current_animation_state]
    player_drawing.update_animation(current_animation, 1 / 60)

    if not (acceleration.x == 0) or not (acceleration.y == 0) then
      animation.direction = acceleration.x > 0 and 1 or -1
    end
  end
end)

return animation_set_state_system

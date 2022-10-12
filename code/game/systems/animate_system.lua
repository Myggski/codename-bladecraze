local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"
local player_drawing = require "code.player.player_drawing"

local animate_query = entity_query.all(components.animation, components.velocity)

local animation_set_state_system = system(animate_query, function(self, dt)
  local animation, velocity, current_animation = nil, nil, nil

  for _, entity in self:entity_iterator() do
    animation = entity[components.animation]
    velocity = entity[components.velocity]

    current_animation = animation[animation.current_animation_state]

    if not animation.freeze_frame then
      player_drawing.update_animation(current_animation, dt)
    end

    if not (velocity.x == 0) or not (velocity.y == 0) then
      if velocity.x > 0 then
        animation.direction = 1
      elseif velocity.x < 0 then
        animation.direction = -1
      end
    end
  end
end)

return animation_set_state_system

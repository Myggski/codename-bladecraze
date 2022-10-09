local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"

local animation_set_state_query = entity_query.all(components.animation)

local animation_set_state_system = system(animation_set_state_query, function(self)
  local animation, acceleration, health = nil, nil, nil

  for _, entity in self:entity_iterator() do
    animation = entity[components.animation]
    acceleration = entity[components.acceleration]
    health = entity[components.health]

    -- Default animation - Idling
    animation.current_animation_state = ANIMATION_STATE_TYPES.IDLE

    -- Is moving
    if acceleration and (not (acceleration.x == 0) or (not acceleration.y == 0))
        and animation.animations[ANIMATION_STATE_TYPES.WALKING] then
      animation.current_animation_state = ANIMATION_STATE_TYPES.WALKING
    end

    -- Is dead
    if health and health <= 0 and animation.animations[ANIMATION_STATE_TYPES.DEAD] then
      animation.current_animation_state = ANIMATION_STATE_TYPES.DEAD
    end
  end
end)

return animation_set_state_system

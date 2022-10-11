local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"

local animation_set_state_query = entity_query.all(components.animation)

local animation_set_state_system = system(animation_set_state_query, function(self)
  local animation, acceleration, health, new_state = nil, nil, nil, nil

  for _, entity in self:entity_iterator() do
    animation = entity[components.animation]
    acceleration = entity[components.acceleration]
    health = entity[components.health]
    new_state = ANIMATION_STATE_TYPES.IDLE

    -- Is moving
    if acceleration and (not (acceleration.x == 0) or not (acceleration.y == 0))
        and animation[ANIMATION_STATE_TYPES.WALKING] then
      new_state = ANIMATION_STATE_TYPES.WALKING
    end

    -- Is dead
    if health and health <= 0 and animation[ANIMATION_STATE_TYPES.DEAD] then
      new_state = ANIMATION_STATE_TYPES.DEAD
    end

    if not (new_state == animation.current_animation_state) then
      animation[animation.current_animation_state].current_time = 0
      animation.current_animation_state = new_state
    end
  end
end)

return animation_set_state_system

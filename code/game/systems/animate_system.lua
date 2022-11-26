local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"

local animate_query = entity_query.all(components.animation)

-- Updates the animation by ticking the animation time and sets the current quad
local function update_animation(animation, dt)
  local current_animation = animation[animation.current_animation_state]

  current_animation.current_time = current_animation.current_time + dt

  if current_animation.current_time > current_animation.duration then
    if animation.current_animation_state == ANIMATION_STATE_TYPES.DEAD then
      animation.freeze_frame = true
      return
    else
      current_animation.current_time = 0
    end
  end

  current_animation.current_quad = current_animation.quads[
      1 + math.floor((current_animation.current_time / current_animation.duration) * #current_animation.quads)]
  _, _, current_animation.viewport.x, current_animation.viewport.y = current_animation.current_quad:getViewport()

  return current_animation
end

local animation_set_state_system = system(animate_query, function(self, dt)
  local animation, velocity = nil, nil

  self:for_each(function(entity)
    animation = entity[components.animation]
    velocity = entity[components.velocity]

    if not animation.freeze_frame then
      update_animation(animation, dt)
    end

    if animation.current_animation_state == ANIMATION_STATE_TYPES.WALKING then
      if velocity.x > 0 then
        animation.direction = 1
      elseif velocity.x < 0 then
        animation.direction = -1
      end
    end
  end)
end)

return animation_set_state_system

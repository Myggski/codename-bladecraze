local collision = require "code.engine.collision"
local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"

local health_filter = entity_query.filter(function(e)
  return e[components.health] > 0
end)

local damager_query = entity_query.all(components.damager, components.box_collider)

local destroy_timer_system = system(damager_query, function(self, dt)
  local position, size, damage, box_collider, box_collider_position = nil, nil, nil, nil, nil
  local found_position, found_box_collider, found_box_collider_position, found_health = nil, nil, nil, nil
  local found_animation, found_entities, found_entity = nil, nil, nil

  self:for_each(function(entity)
    position = entity[components.position]
    box_collider = entity[components.box_collider]
    size = entity[components.size]
    damage = entity[components.damager]
    box_collider_position = collision.get_collider_position(position, box_collider)
    found_entities = self:find_at(position, size, set.create({ entity }))

    for i = 1, #found_entities do
      found_entity = found_entities[i]
      found_health = found_entity[components.health]

      -- If it has no health, it has no health to loose
      if not found_health or found_health <= 0 then
        goto continue
      end

      found_position = found_entity[components.position]
      found_box_collider = found_entity[components.box_collider]
      found_animation = found_entity[components.animation]
      found_box_collider_position = collision.get_collider_position(found_position, found_box_collider)

      -- If not overlapping with a box_collider, it should not loose health
      if not
          collision.is_touching(
            box_collider_position, box_collider.size,
            found_box_collider_position, found_box_collider.size) then

        goto continue
      end

      found_health = found_health - damage

      if found_health <= 0 and not found_animation[ANIMATION_STATE_TYPES.DEAD] then
        found_entity:destroy()
      else
        if found_health <= 0 and found_animation[ANIMATION_STATE_TYPES.DEAD] and
            not (found_animation.current_animation_state == ANIMATION_STATE_TYPES.DEAD) then
          found_entity[components.destroy_timer] = found_animation[ANIMATION_STATE_TYPES.DEAD].duration
        end

        found_entity[components.health] = found_health
      end

      ::continue::
    end
  end)
end)

return destroy_timer_system

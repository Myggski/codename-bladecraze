local collision = require "code.engine.collision"
local components = require "code.engine.components"
local debug = require "code.engine.debug"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"

local damager_query = entity_query.all(components.damager, components.box_collider)

local destroy_timer_system = system(damager_query, function(self, dt)
  local position, size, damage, box_collider, box_collider_position = nil, nil, nil, nil, nil
  local found_position, found_box_collider, found_box_collider_position, found_health = nil, nil, nil, nil
  local found_entities = nil

  self:for_each(function(entity)
    position = entity[components.position]
    box_collider = entity[components.box_collider]
    size = entity[components.size]
    damage = entity[components.damager]
    box_collider_position = collision.get_collider_position(position, box_collider)

    found_entities = self:find_at(position, size, set.create { entity })

    for found_entity, _ in pairs(found_entities) do
      found_health = found_entity[components.health]

      -- If it has no health, it has no health to loose
      if not found_health then
        goto continue
      end

      found_position = found_entity[components.position]
      found_box_collider = found_entity[components.box_collider]
      found_box_collider_position = collision.get_collider_position(found_position, found_box_collider)

      -- If not overlapping with a box_collider, it should not loose health
      if not collision.overlap(
        box_collider_position, box_collider.size,
        found_box_collider_position, found_box_collider.size
      ) then
        goto continue
      end

      found_health = found_health - damage

      if found_health <= 0 then
        found_entity:destroy()
      else
        found_entity[components.health] = found_health
      end

      ::continue::
    end
  end)
end)

return destroy_timer_system

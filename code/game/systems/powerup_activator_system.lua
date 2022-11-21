local collision = require "code.engine.collision"
local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local powerup = require "code.game.entities.powerups.powerup"
local gizmos = require "code.engine.debug.gizmos"
local grid = require "code.engine.world_grid"
local vector2 = require "code.engine.vector2"
local player_query = entity_query.all(components.player_stats)

local powerup_activator_system = system(player_query, function(self, dt)
  local position, size, damage, box_collider, box_collider_position = nil, nil, nil, nil, nil
  local found_entities = nil

  self:for_each(function(entity)
    position = entity[components.position]
    box_collider = entity[components.box_collider]
    size = entity[components.size]
    damage = entity[components.damager]
    box_collider_position = collision.get_collider_position(position, box_collider)
    found_entities = self:find_at(position, size, set.create({ entity }))
    -- gizmos.draw_rectangle(position,
    --   size, nil, nil, 5, 0)
    for other_entity, _ in pairs(found_entities) do
      found_position = other_entity[components.position]
      found_box_collider = other_entity[components.box_collider]
      found_box_collider_position = collision.get_collider_position(found_position, found_box_collider)

      -- If not overlapping with a box_collider, it should not loose health
      if not
          collision.is_touching(
            box_collider_position, box_collider.size,
            found_box_collider_position, found_box_collider.size) then

        goto continue
      end
      print("äre touch")
      --if (other_entity:has_component(components.))
      --player_stats = other_entity[components.player_stats]

      -- If it has no health, it has no health to loose
      --if player_stats then
      -- add stats, destroy powerup
      --break
      --end

      --add stats
      --player_stats
      ::continue::
    end
  end)
end)

return powerup_activator_system

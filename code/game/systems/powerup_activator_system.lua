local collision = require "code.engine.collision"
local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local powerup = require "code.game.entities.powerups.powerup"
local gizmos = require "code.engine.debug.gizmos"
local grid = require "code.engine.world_grid"
local vector2 = require "code.engine.vector2"
local debug = require "code.engine.debug"

local player_query = entity_query.all(components.input, components.box_collider)

local powerup_activator_system = system(player_query, function(self, dt)
  local position, size, damage, box_collider, box_collider_position = nil, nil, nil, nil, nil
  local player_stats = nil
  local found_entities = nil
  self:for_each(function(entity)
    player_stats = entity[components.player_stats]
    position = entity[components.position]
    box_collider = entity[components.box_collider]
    size = entity[components.size]
    local pos = grid:convert_to_world(position)
    box_collider_position = collision.get_collider_position(position, box_collider)
    found_entities = self:find_at(position, size, set.create({ entity })) --hittar bara bomber å eld, inte powerups :(
    gizmos.draw_rectangle(position,
      size, nil, COLOR.BLUE, 2, 0)

    for other_entity, _ in pairs(found_entities) do
      local found_box_collider = other_entity[components.box_collider]
      if not found_box_collider then
        goto continue
      end

      local found_position = other_entity[components.position]
      local found_box_collider_position = collision.get_collider_position(found_position, found_box_collider)
      local found_stats = other_entity[components.player_stats]

      -- If not overlapping with a box_collider, it should not loose health
      if not
          collision.is_touching(
            box_collider_position, box_collider.size,
            found_box_collider_position, found_box_collider.size) then
        goto continue
      end
      if (other_entity.archetype == powerup.archetype) then
        debug.print_execution_time_formatted("safe add: ", debug.TIME_FORMAT.MICRO, table.add_numeric, player_stats,
          found_stats)
        debug.print_execution_time_formatted("unsafe add: ", debug.TIME_FORMAT.MICRO, table.add_numeric_unsafe,
          player_stats, found_stats)
        other_entity:destroy()
      end
      ::continue::
    end

  end)
end)

return powerup_activator_system

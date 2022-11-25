local collision = require "code.engine.collision"
local components = require "code.engine.components"
local system = require "code.engine.ecs.system"
local powerup = require "code.game.entities.powerups.powerup"
local player = require "code.game.entities.player"

local powerup_activator_system = system(function(self, dt)
  local position, size, box_collider, box_collider_position
  local player_stats, found_entities

  self:for_each(function(entity)
    player_stats = entity[components.player_stats]
    position = entity[components.position]
    box_collider = entity[components.box_collider]
    size = entity[components.size]
    box_collider_position = collision.get_collider_position(position, box_collider)
    found_entities = self:find_at(position, size, set.create({ entity }))

    for other_entity, _ in pairs(found_entities) do
      local found_box_collider = other_entity[components.box_collider]
      if not found_box_collider then
        goto continue
      end

      local found_position = other_entity[components.position]
      local found_box_collider_position = collision.get_collider_position(found_position, found_box_collider)
      local found_stats = other_entity[components.player_stats]

      if not
          collision.is_touching(
            box_collider_position, box_collider.size,
            found_box_collider_position, found_box_collider.size) then
        goto continue
      end

      if (other_entity.archetype == powerup:get_archetype()) then
        table.add_numeric_unsafe(player_stats, found_stats)
        other_entity:destroy()
      end
      ::continue::
    end

  end, player:get_archetype())
end)

return powerup_activator_system

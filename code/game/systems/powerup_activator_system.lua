local collision = require "code.engine.collision"
local components = require "code.engine.components"
local system = require "code.engine.ecs.system"
local powerup = require "code.game.entities.powerups.powerup"
local player = require "code.game.entities.player"
local audio = require "code.engine.audio"

local powerup_activator_system = system(function(self, dt)
  local position, size, box_collider, box_collider_position = nil, nil, nil, nil
  local player_stats, found_entities, found_entity = nil, nil, nil

  self:for_each(function(entity)
    player_stats = entity[components.player_stats]
    position = entity[components.position]
    box_collider = entity[components.box_collider]
    size = entity[components.size]
    box_collider_position = collision.get_collider_position(position, box_collider)
    found_entities = self:find_at(position, size, set.create({ entity }))

    for i = 1, #found_entities do
      found_entity = found_entities[i]
      local found_box_collider = found_entity[components.box_collider]
      if not found_box_collider then
        goto continue
      end

      local found_position = found_entity[components.position]
      local found_box_collider_position = collision.get_collider_position(found_position, found_box_collider)
      local found_stats = found_entity[components.player_stats]

      if not
          collision.is_touching(
            box_collider_position, box_collider.size,
            found_box_collider_position, found_box_collider.size) then
        goto continue
      end

      if (found_entity.archetype == powerup:get_archetype()) then
        audio:play("powerup.wav")
        table.add_numeric_unsafe(player_stats, found_stats)
        found_entity:destroy()
      end
      ::continue::
    end

  end, player:get_archetype())
end)

return powerup_activator_system

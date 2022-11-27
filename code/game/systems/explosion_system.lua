local collision = require "code.engine.collision"
local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local fire = require "code.game.entities.fire"
local system = require "code.engine.ecs.system"
local vector2 = require "code.engine.vector2"
local audio = require "code.engine.audio"

local explosion_query = entity_query.all(components.explosion_radius)

local directions = { vector2.up(), vector2.down(), vector2.left(), vector2.right() }

local explosion_system = system(explosion_query, function(self, dt)
  local position, explosion_radius, player_stats = nil, nil, nil
  local spawn_position, found_entities, new_fire = nil, nil, nil
  local found_entity, found_position, found_box_collider, found_box_collider_position = nil, nil, nil, nil
  local fire_position, fire_box_collider, fire_box_collider_position, found_health = nil, nil, nil, nil

  self:for_each(function(entity)
    if entity:is_alive() then
      return
    end

    position = entity[components.position]
    explosion_radius = entity[components.explosion_radius]
    player_stats = entity[components.player_stats]

    audio:play("explosion.wav", love.math.random(70, 105) / 100)
    fire.create(self:get_world(), position)
    for _, direction in ipairs(directions) do
      for radius = 1, explosion_radius do
        spawn_position = position + (direction * radius)
        new_fire = fire.create(self:get_world(), spawn_position)
        fire_position = new_fire[components.position]
        fire_box_collider = new_fire[components.box_collider]
        fire_box_collider_position = collision.get_collider_position(fire_position, fire_box_collider)

        -- Checks for entities in in at the fire position
        found_entities = self:find_at(spawn_position, vector2.one(),
          set.create({ entity, new_fire }))

        -- Checks if the fire collides with anything
        for i = 1, #found_entities do
          found_entity = found_entities[i]
          found_position = found_entity[components.position]
          found_health = found_entity[components.health]
          found_box_collider = found_entity[components.box_collider]

          if not found_box_collider then
            goto next_entity
          end

          found_box_collider_position = collision.get_collider_position(found_position, found_box_collider)

          -- If the fire collides with something, it stops spawning at the current direction
          -- Unless it collides with fire (same kind), then it should continue
          if not (found_entity.archetype == new_fire.archetype) and collision.overlap(
            fire_box_collider_position, fire_box_collider.size,
            found_box_collider_position, found_box_collider.size
          ) then
            if not found_health then
              new_fire:destroy()
            end

            goto next_direction
          end

          ::next_entity::
        end
      end

      ::next_direction::
    end

    player_stats.available_bombs = player_stats.available_bombs + 1
  end)
end)

return explosion_system

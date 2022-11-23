local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local wall = require "code.game.entities.walls.destructible_wall"
local powerup = require "code.game.entities.powerups.powerup"

local dead_query = entity_query.all(components.health, components.box_collider)

local powerup_spawner_system = system(dead_query, function(self, dt)
  self:for_each(function(entity)
    if (not entity:is_alive()) then
      powerup.create(self:get_world(), entity[components.position])
    end
  end, wall.archetype)
end)

return powerup_spawner_system

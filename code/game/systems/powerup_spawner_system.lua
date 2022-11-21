local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local wall = require "code.game.entities.walls.destructible_wall"
local powerup = require "code.game.entities.powerups.powerup"

local alive_filter = entity_query.filter(function(e)
  return e:is_alive() == true
end)

local dead_query = entity_query.all(components.health, components.box_collider).none(alive_filter())

local powerup_spawner_system = system(dead_query, function(self, dt)
  self:for_each(function(entity)
    if (entity.archetype == wall.archetype) then
      powerup.create(self:get_world(), entity[components.position])
    end
  end)
end)

return powerup_spawner_system

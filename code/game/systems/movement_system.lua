local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local world_grid = require "code.engine.world_grid"
local vector2 = require "code.engine.vector2"

local movement_query = entity_query.all(
  components.position,
  components.velocity
).none(components.target_position)

local movement_system = system(movement_query, function(self, dt)
  local position, velocity, previous_position = nil, nil, nil

  self:for_each(function(entity)
    position = entity[components.position]
    velocity = entity[components.velocity]

    position.x = position.x + world_grid:convert_to_world(velocity.x * dt)
    position.y = position.y + world_grid:convert_to_world(velocity.y * dt)

    if not (position == previous_position) then
      self:update_collision_grid(entity)
    end
  end)
end)

return movement_system

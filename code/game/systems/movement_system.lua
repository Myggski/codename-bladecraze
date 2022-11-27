local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"

local movement_query = entity_query.all(
  components.position,
  components.size,
  components.velocity
).none(components.target_position)

local movement_system = system(movement_query, function(self, dt)
  local position, velocity, previous_position = nil, nil, nil

  self:for_each(function(entity)
    position = entity[components.position]
    velocity = entity[components.velocity]

    previous_position = position:copy()
    position.x = position.x + velocity.x * dt
    position.y = position.y + velocity.y * dt

    if not (position == previous_position) then
      self:update_collision_grid(entity)
    end
  end)
end)

return movement_system

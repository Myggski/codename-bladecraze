local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local world_grid = require "code.engine.world_grid"
local vector2 = require "code.engine.vector2"

local target_movement_query = entity_query.all(
  components.position,
  components.acceleration,
  components.target_position
).none(components.input)

local target_movement_system = system(target_movement_query, function(self, dt)
  local position, acceleration, target, velocity = nil, nil, nil, vector2.zero()
  local dist, dir_x, dir_y = nil, nil, nil

  self:for_each(function(entity)
    position = entity[components.position]
    acceleration = entity[components.acceleration]
    target = entity[components.target_position]
    if not target or target == position then
      return
    end

    dir_x, dir_y, dist = math.normalize(target.x - position.x, target.y - position.y)
    velocity.x = velocity.x + (dir_x * acceleration.speed) * dt
    velocity.y = velocity.y + (dir_y * acceleration.speed) * dt

    -- Goal reached
    if dist > 0.05 then
      position.x = position.x + world_grid:convert_to_world(velocity.x * dt)
      position.y = position.y + world_grid:convert_to_world(velocity.y * dt)
    else
      position.x, position.y = target.x, target.y
    end

    self:update_collision_grid(entity)
  end)
end)

return target_movement_system

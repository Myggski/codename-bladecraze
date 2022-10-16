local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"
local world_grid = require "code.engine.world_grid"

local target_movement_query = entity_query.all(
  components.position,
  components.acceleration,
  components.target_position
).none(components.input)

local target_movement_system = system(target_movement_query, function(self, dt)
  local position, acceleration, target, velocity = nil, nil, nil, { x = 0, y = 0 }
  local dist, dir_x, dir_y = nil, nil, nil

  for _, entity in self:entity_iterator() do
    position = entity[components.position]
    acceleration = entity[components.acceleration]
    target = entity[components.target_position]

    if not target then
      return
    end

    dir_x, dir_y, dist = math.normalize(target.x - position.x, target.y - position.y)
    velocity.x = velocity.x + (dir_x * acceleration.speed) * dt
    velocity.y = velocity.y + (dir_y * acceleration.speed) * dt

    if dist < 0.05 then
      position.x, position.y = target.x, target.y
    end

    if not (position.x == target.x) or not (position.y == target.y) then
      position.x = position.x + world_grid:convert_to_world(velocity.x * dt)
      position.y = position.y + world_grid:convert_to_world(velocity.y * dt)
    end
  end
end)

return target_movement_system

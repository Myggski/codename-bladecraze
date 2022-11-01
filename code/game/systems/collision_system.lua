local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local collision = require "code.engine.collision"
local vector2 = require "code.engine.vector2"
local debug = require "code.engine.debug"

local collision_filter = entity_query.filter(function(entity)
  return entity[components.box_collider] and entity[components.box_collider].enabled
end)

local collision_query = entity_query.all(components.position, components.size, components.box_collider,
  collision_filter())

local function opposite_direction(key)
  return key == "x" and "y" or "x"
end

local function position_rounding(self, entity, found_entity, key, dt)
  local found_input = found_entity[components.input]

  if not found_input then
    return false
  end

  local direction = found_input.movement_direction

  if direction[opposite_direction(key)] == 0 then
    return false
  end

  local found_position = found_entity[components.position]
  local found_size = found_entity[components.size]
  local found_velocity = found_entity[components.velocity]
  local found_acceleration = found_entity[components.acceleration]
  local found_box_collider = found_entity[components.box_collider]
  local found_collider_position = collision.get_collider_position(found_position, found_box_collider)
  local collider_position = collision.get_collider_position(entity[components.position], entity[components.box_collider])
  local rounded_found_collider_position = vector2(
    math.round(found_collider_position.x),
    math.round(found_collider_position.y)
  )

  local moving_towards_position = rounded_found_collider_position:copy()
  moving_towards_position[opposite_direction(key)] = moving_towards_position[opposite_direction(key)] +
      direction[opposite_direction(key)]

  -- If sliding towards the obstacle, do not slide
  if moving_towards_position == collider_position then
    return false
  end

  local direction, distance = math.normalize2(rounded_found_collider_position - found_collider_position)

  -- If the character is moving in the same direction as the rounding position, do nothing
  if not (found_input.movement_direction[key] == 0) then
    return false
  end

  -- If the character is near the rounded position, round the character position
  if math.abs(distance) < 0.05 then
    local rounding_value = math.round(found_position[key]) - (found_size[key] - found_box_collider.size[key])
    found_velocity[key] = 0
    found_position[key] = rounding_value
    self:update_collision_grid(found_entity)
    return true
  end

  -- Moving towards the rounding position
  found_velocity[key] = found_velocity[key] +
      ((math.round(direction[key]) * found_acceleration.speed) - (found_velocity[key] * found_acceleration.friction)
      ) * dt
  return false
end

-- Collision System - Runs every frame
local collision_system = system(collision_query, function(self, dt)
  local position, box_collider, collider_position = nil, nil, nil
  local found_entities, found_position, found_box_collider, found_collider_position, found_velocity = nil, nil, nil, nil
      , nil
  local new_position = nil

  self:for_each(function(entity)
    position, box_collider = entity[components.position], entity[components.box_collider]
    collider_position = collision.get_collider_position(position, box_collider)

    found_entities = self:find_near_entities(collider_position, box_collider.size * 1.25, set.create { entity })

    for found_entity, _ in pairs(found_entities) do
      found_position, found_box_collider = found_entity[components.position], found_entity[components.box_collider]
      found_velocity = found_entity[components.velocity]

      if not found_velocity then
        goto continue
      end

      found_collider_position = collision.get_collider_position(found_position, found_box_collider)
      local rounded_found_collider_position = vector2(
        math.round(found_collider_position.x),
        math.round(found_collider_position.y)
      )
      local velocity_direction = vector2(math.sign(found_velocity.x), math.sign(found_velocity.y))

      local moving_towards_position_x = rounded_found_collider_position:copy()
      moving_towards_position_x.x = moving_towards_position_x.x + velocity_direction.x

      local moving_towards_position_y = rounded_found_collider_position:copy()
      moving_towards_position_y.y = moving_towards_position_y.y + velocity_direction.y




      -- Checking collision on the x-axis
      new_position = vector2(found_collider_position.x + found_velocity.x * dt, found_collider_position.y)
      if collision.overlap(collider_position, box_collider.size, new_position, found_box_collider.size) and
          math.normalize2(moving_towards_position_x - collider_position).x == 0 then
        position_rounding(self, entity, found_entity, "y", dt)
        found_velocity.x = 0
      end

      -- Checking collision on the y-axis
      new_position = vector2(found_collider_position.x, found_collider_position.y + found_velocity.y * dt)
      if collision.overlap(collider_position, box_collider.size, new_position, found_box_collider.size) and
          math.normalize2(moving_towards_position_y - collider_position).y == 0 then
        position_rounding(self, entity, found_entity, "x", dt)
        found_velocity.y = 0
      end

      ::continue::
    end
  end, collision_query)
end)

return collision_system

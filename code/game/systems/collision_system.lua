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
  local diagonal = not (direction.x == 0) and not (direction.y == 0)

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

  if diagonal and not self.movement_key then
    self.movement_key = key
  elseif not diagonal and self.movement_key then
    self.movement_key = nil
  end

  if diagonal and not (key == self.movement_key) then
    print("HELLO", self.movement_key, key)
    found_velocity[key] = 0
    return false
  end

  local moving_towards_position = rounded_found_collider_position:copy()
  moving_towards_position[opposite_direction(key)] = moving_towards_position[opposite_direction(key)] +
      direction[opposite_direction(key)]

  -- If moving towards the obstacle, do not slide
  if moving_towards_position == collider_position then
    return false
  end

  local direction, distance = math.normalize2(rounded_found_collider_position - found_collider_position)

  if math.round(found_input.movement_direction[key]) == math.round(direction[key]) then
    return false
  end

  debug.gizmos.draw_rectangle(rounded_found_collider_position * 16, found_box_collider.size * 16, "line", COLOR.CYAN)
  debug.gizmos.draw_rectangle(moving_towards_position * 16, found_box_collider.size * 16, "line", COLOR.GREEN)
  debug.gizmos.draw_rectangle(collider_position * 16, found_box_collider.size * 16, "line", COLOR.RED)

  if math.abs(distance) < 0.02 then
    local rounding_value = math.round(found_position[key]) - (found_size[key] - found_box_collider.size[key])
    found_velocity[key] = 0
    found_position[key] = rounding_value
    self:update_collision_grid(found_entity)
    self.movement_key = opposite_direction(key)
    return true
  end

  found_velocity[key] = found_velocity[key] +
      ((math.round(direction[key]) * found_acceleration.speed * 4) - (found_velocity[key] * found_acceleration.friction)
      ) * dt
  return false
end

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

      if not found_box_collider or not found_velocity then
        goto continue
      end

      found_collider_position = collision.get_collider_position(found_position, found_box_collider)

      local rounded_found_collider_position = vector2(
        math.round(found_collider_position.x),
        math.round(found_collider_position.y)
      )

      debug.gizmos.draw_rectangle(rounded_found_collider_position *
        16, vector2.one() * 16, "fill", COLOR.RED)

      -- Checking the x velocity if it collides
      new_position = vector2(found_collider_position.x + found_velocity.x * dt, found_collider_position.y)
      if collision.overlap(collider_position, box_collider.size, new_position, found_box_collider.size) then
        position_rounding(self, entity, found_entity, "y", dt)
        found_velocity.x = 0
      end

      -- Checking the y velocity if it collides
      new_position = vector2(found_collider_position.x, found_collider_position.y + found_velocity.y * dt)
      if collision.overlap(collider_position, box_collider.size, new_position, found_box_collider.size) then
        position_rounding(self, entity, found_entity, "x", dt)
        found_velocity.y = 0
      end

      ::continue::
    end
  end, collision_query)
end)

return collision_system

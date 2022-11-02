local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local collision = require "code.engine.collision"
local vector2 = require "code.engine.vector2"
local debug = require "code.engine.debug"

local collision_filter = entity_query.filter(function(entity)
  return entity[components.box_collider] and entity[components.box_collider].enabled
end)

local collision_query = entity_query.all(
  components.position,
  components.size,
  components.box_collider,
  components.velocity,
  collision_filter()
)

local function opposite_key(key)
  return key == "x" and "y" or "x"
end

local function round_position(self, entity, key)
  local box_collider = entity[components.box_collider]
  local position = entity[components.position]
  local size = entity[components.size]
  local velocity = entity[components.velocity]

  velocity[key] = 0
  position[key] = math.round(position[key]) - (size[key] - box_collider.size[key])
  self:update_collision_grid(entity)
end

local function try_adjust_position(self, entity, found_entity, key, dt)
  local input = entity[components.input]
  local direction = input.movement_direction
  local position = entity[components.position]
  local velocity = entity[components.velocity]
  local acceleration = entity[components.acceleration]
  local box_collider = entity[components.box_collider]
  local opposite_key_direction = opposite_key(key)
  local collider_position = collision.get_collider_position(position, box_collider)
  local found_collider_position = collision.get_collider_position(found_entity[components.position],
    found_entity[components.box_collider])
  local rounded_collider_position = vector2(
    math.round(collider_position.x),
    math.round(collider_position.y)
  )

  local moving_towards_position = rounded_collider_position:copy()
  moving_towards_position[opposite_key_direction] = moving_towards_position[opposite_key_direction] +
      math.sign(direction[opposite_key_direction])

  -- If the entity is moving towards an obstacle or not moving at all when it collides, it should round the position
  if moving_towards_position == found_collider_position or direction[opposite_key_direction] == 0 then
    round_position(self, entity, opposite_key_direction)

    return true
  end

  -- Get direction on where to slide to and the distance to the sliding destination
  local slide_direction, slide_distance = math.normalize2(rounded_collider_position - collider_position)
  local is_moving = math.sign(input.movement_direction[key]) == 0
  local is_moving_towards_slide = math.sign(input.movement_direction[key]) == math.round(slide_direction[key])

  -- If the character is not moving in the same direction as the slide direction
  if not is_moving and not is_moving_towards_slide then
    -- Is close enough to the slide position, the position should be rounded
    if slide_distance < 0.09 then
      round_position(self, entity, opposite_key_direction)

      return true
    end

    velocity[opposite_key_direction] = 0
    print(key, position.x, position.y)
    return false
  end

  -- If the character is near the rounded position, round the character position
  if math.abs(slide_distance) < 0.09 then
    round_position(self, entity, key)

    return true
  end

  -- Fixing rounding problem(?)
  if not (collider_position[opposite_key_direction] == math.round(collider_position[opposite_key_direction]))
      and velocity[opposite_key_direction] == 0
      and math.abs(position[opposite_key_direction] - math.round(position[opposite_key_direction])) < 0.09 then
    round_position(self, entity, opposite_key_direction)

    return true
  end

  -- Move closer to the slide position
  velocity[key] = velocity[key]
      + ((math.sign(slide_direction[key]) * acceleration.speed)
          - (velocity[key] * acceleration.friction))
      * dt

  return false
end

-- Collision System - Runs every frame
local collision_system = system(collision_query, function(self, dt)
  local position, box_collider, velocity, collider_position = nil, nil, nil, nil
  local found_entities, found_position, found_box_collider = nil, nil, nil
  local found_collider_position, rounded_found_collider_position = nil, nil
  local new_position, rounded_collider_position, velocity_direction = nil, nil, nil
  local moving_towards_position_x, moving_towards_position_y = nil, nil
  local position_y_adjusted, position_adjusted = nil, nil

  self:for_each(function(entity)
    position = entity[components.position]
    box_collider = entity[components.box_collider]
    velocity = entity[components.velocity]

    collider_position = collision.get_collider_position(position, box_collider)
    found_entities = self:find_near_entities(collider_position, box_collider.size, set.create({ entity }))
    for found_entity, _ in pairs(found_entities) do
      found_position, found_box_collider = found_entity[components.position], found_entity[components.box_collider]

      -- Checks ignore-list (should move this to spatial grid)
      if box_collider.ignore and set.contains(box_collider.ignore, found_entity.archetype) or not found_box_collider then
        goto continue
      end


      velocity_direction = vector2(math.sign(velocity.x), math.sign(velocity.y))
      rounded_collider_position = vector2(
        math.round(collider_position.x),
        math.round(collider_position.y)
      )

      -- Checking collision on the x-axis
      new_position = vector2(collider_position.x + velocity.x * dt, collider_position.y)
      found_collider_position = collision.get_collider_position(found_position, found_box_collider)
      rounded_found_collider_position = vector2(
        math.round(found_collider_position.x),
        math.round(found_collider_position.y)
      )

      moving_towards_position_x = rounded_collider_position:copy()
      moving_towards_position_x.x = moving_towards_position_x.x + velocity_direction.x
      position_y_adjusted = false

      if collision.overlap(found_collider_position, found_box_collider.size, new_position, box_collider.size)
          and math.normalize2(moving_towards_position_x - rounded_found_collider_position).x == 0 then
        position_adjusted = try_adjust_position(self, entity, found_entity, "y", dt)
        if not position_adjusted then
          velocity.x = 0
          position_y_adjusted = true
        end
      end

      -- Checking collision on the y-axis
      collider_position = collision.get_collider_position(position, box_collider)

      velocity_direction = vector2(math.sign(velocity.x), math.sign(velocity.y))
      rounded_collider_position = vector2(
        math.round(collider_position.x),
        math.round(collider_position.y)
      )

      -- Fixing scuffed problem
      if not (collider_position.x == math.round(collider_position.x))
          and velocity.x == 0
          and math.abs(position.x - math.round(position.x)) < 0.09 then
        round_position(self, entity, "x")

        return true
      end

      new_position = vector2(collider_position.x, collider_position.y + velocity.y * dt)
      found_collider_position = collision.get_collider_position(found_position, found_box_collider)
      rounded_found_collider_position = vector2(
        math.round(found_collider_position.x),
        math.round(found_collider_position.y)
      )

      moving_towards_position_y = rounded_collider_position:copy()
      moving_towards_position_y.y = moving_towards_position_y.y + velocity_direction.y

      if not position_y_adjusted
          and collision.overlap(found_collider_position, found_box_collider.size, new_position, box_collider.size)
          and math.normalize2(moving_towards_position_y - rounded_found_collider_position).y == 0 then
        position_adjusted = try_adjust_position(self, entity, found_entity, "x", dt)
        if not position_adjusted then
          velocity.y = 0
        end

      end

      ::continue::
    end
  end)
end)

return collision_system

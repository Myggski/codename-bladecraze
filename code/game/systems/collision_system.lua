local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local collision = require "code.engine.collision"
local vector2 = require "code.engine.vector2"
local gizmos = require "code.engine.debug.gizmos"
local grid = require "code.engine.world_grid"

local AXIS_KEYS = {
  X = "x",
  Y = "y",
}

local function opposite_key(key)
  return key == AXIS_KEYS.X and AXIS_KEYS.Y or AXIS_KEYS.X
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

local function position_equal_threshold(position_a, position_b, threshold)
  local x_diff = math.abs(position_a.x - position_b.x)
  local y_diff = math.abs(position_a.y - position_b.y)
  return x_diff <= threshold and y_diff <= threshold
end

local function try_adjust_position(self, entity, other_entity, key, dt)
  local input = entity[components.input]
  local direction = input.movement_direction
  local position = entity[components.position]
  local velocity = entity[components.velocity]
  local acceleration = entity[components.acceleration]
  local box_collider = entity[components.box_collider]
  local new_velocity = 0
  local opposite_key_direction = opposite_key(key)
  local collider_position = collision.get_collider_position(position, box_collider)
  local other_collider_position = collision.get_collider_position(
    other_entity[components.position],
    other_entity[components.box_collider]
  )
  local rounded_collider_position = vector2(
    math.round(collider_position.x),
    math.round(collider_position.y)
  )
  local moving_towards_position = rounded_collider_position:copy()
  moving_towards_position[opposite_key_direction] = moving_towards_position[opposite_key_direction] +
      math.sign(direction[opposite_key_direction])

  -- If the entity is inside the collider, do nothing, so it can leave the obstacle
  if position_equal_threshold(rounded_collider_position, other_collider_position, 0.15) then
    return false
  end

  -- If entity is moving towards an obsticle, round the position
  if position_equal_threshold(moving_towards_position, other_collider_position, 0.15) then
    round_position(self, entity, opposite_key_direction)
    return true
  end

  -- If the entity is moving towards an obstacle or not moving at all when it collides, it should round the position
  if direction[opposite_key_direction] == 0 then
    velocity[opposite_key_direction] = 0

    return false -- If movement is weird, change this to true(?)
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
    return false
  end

  -- If the character is near the rounded position, round the character position
  if math.abs(slide_distance) < 0.09 then
    round_position(self, entity, key)

    return true
  end

  -- Move closer to the slide position
  new_velocity = (math.sign(slide_direction[key]) * acceleration.speed) - (velocity[key] * acceleration.friction)
  velocity[key] = velocity[key] + new_velocity * dt

  return false
end

local function try_handle_collision(self, entity, other_entity, key, dt)
  local position = entity[components.position]
  local box_collider = entity[components.box_collider]
  local velocity = entity[components.velocity]
  local other_box_collider = other_entity[components.box_collider]
  local collider_position = collision.get_collider_position(position, box_collider)
  local other_collider_position = collision.get_collider_position(other_entity[components.position], other_box_collider)
  local rounded_other_collider_position = vector2(
    math.round(other_collider_position.x),
    math.round(other_collider_position.y)
  )
  local moving_to_position = vector2(
    math.round(collider_position.x),
    math.round(collider_position.y)
  )
  moving_to_position[key] = moving_to_position[key] + math.sign(velocity[key])

  local new_position = vector2(collider_position.x, collider_position.y)
  new_position[key] = new_position[key] + velocity[key] * dt

  local overlapping_obstacle = collision.overlap(
    rounded_other_collider_position, other_box_collider.size,
    new_position, box_collider.size
  )

  -- if not overlapping_obstacle then
  --   gizmos.draw_rectangle(rounded_other_collider_position * 16, vector2(1, 1) * 16, "line", COLOR.BLACK)
  -- end

  local is_moving_towards_obstacle = math.normalize2(moving_to_position - rounded_other_collider_position)[key] == 0
  if overlapping_obstacle and is_moving_towards_obstacle then
    if not try_adjust_position(self, entity, other_entity, opposite_key(key), dt) then
      velocity[key] = 0
      return true
    end
  end

  return false
end

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

-- Collision System - Runs every frame
local collision_system = system(collision_query, function(self, dt)
  local position, box_collider, collider_position = nil, nil, nil
  local other_entities, other_box_collider, collision_handled = nil, nil, nil

  self:for_each(function(entity)
    position = entity[components.position]
    box_collider = entity[components.box_collider]
    collider_position = collision.get_collider_position(position, box_collider)
    other_entities = self:find_near_entities(collider_position, vector2(3, 3), set.create({ entity }))

    for other_entity, _ in pairs(other_entities) do
      other_box_collider = other_entity[components.box_collider]

      -- Checks ignore-list (should move this to spatial grid)
      if not other_box_collider
          or not other_box_collider.enabled
          or box_collider.ignore and set.contains(box_collider.ignore, other_entity.archetype) then
        goto continue
      end

      -- Checking collision for x-axis
      collision_handled = try_handle_collision(self, entity, other_entity, AXIS_KEYS.X, dt)

      -- If it didn't collide, check y-axis
      if not collision_handled then
        try_handle_collision(self, entity, other_entity, AXIS_KEYS.Y, dt)
      end

      ::continue::
    end
  end)
end)

return collision_system

local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local collision = require "code.engine.collision"
local utilities = require "code.engine.utilities"
local vector2 = require "code.engine.vector2"
local debug = require "code.engine.debug"
local world_grid = require "code.engine.world_grid"

local collision_filter = entity_query.filter(function(entity)
  return entity[components.box_collider] and entity[components.box_collider].enabled
end)

local collision_query = entity_query.all(components.position, components.size, components.box_collider,
  collision_filter())

local function try_round_position_y(self, entity, found_entity, dt)
  local position, box_collider = entity[components.position], entity[components.box_collider]
  local collider_position = collision.get_collider_position(position, box_collider)

  local found_position, found_box_collider = found_entity[components.position], found_entity[components.box_collider]
  local found_collider_position = collision.get_collider_position(found_position, found_box_collider)
  local found_acceleration, found_velocity = found_entity[components.acceleration], found_entity[components.velocity]
  local rounded_found_collider_position = vector2(
    math.round(found_collider_position.x),
    math.round(found_collider_position.y)
  )

  local vector_direction = vector2(math.sign(found_velocity.x), math.sign(found_velocity.y))
  local slide_towards_tile = vector2(
    rounded_found_collider_position.x,
    rounded_found_collider_position.y + vector_direction.y
  )
  local moving_towards_tile = vector2(
    rounded_found_collider_position.x + vector_direction.x,
    rounded_found_collider_position.y + vector_direction.y
  )

  local direction = math.sign(slide_towards_tile.y - found_collider_position.y)
  local possible_colliders = self:find_at(moving_towards_tile,
    vector2.one(), set.create({ found_entity }))

  for possible_collider, _ in pairs(possible_colliders) do
    if possible_collider == entity and
        collision.overlap(collider_position, box_collider.size, moving_towards_tile, vector2.one()) then
      return false
    end
  end

  debug.gizmos.draw_rectangle(slide_towards_tile * 16, vector2.one() * 16, "fill", COLOR.BLUE)

  debug.gizmos.draw_rectangle(moving_towards_tile * 16, vector2.one() * 16, "fill", COLOR.CYAN)
  debug.gizmos.draw_rectangle(vector2(moving_towards_tile.x, math.round(found_collider_position.y)) * 16,
    vector2.one() * 16, "fill"
    , COLOR.WHITE)
  local test = vector2(moving_towards_tile.x, math.round(found_collider_position.y))
  print(math.abs(math.dist_vector(test, found_collider_position)) - 1)
  if math.abs(math.dist_vector(slide_towards_tile, found_collider_position) - 1) < 0.1 and
      math.abs(math.dist_vector(test, found_collider_position)) - 1 < 0.05 and not (test == collider_position) then

    found_velocity.y = 0
    found_position.y = math.round(found_position.y) - (found_entity[components.size].y - found_box_collider.size.y)
    self:update_collision_grid(found_entity)
    return true
  end

  found_velocity.y = found_velocity.y +
      ((direction * found_acceleration.speed) - (found_velocity.y * found_acceleration.friction)) * dt

  return false
end

local function try_round_position_x(self, entity, found_entity, dt)
  local position, box_collider = entity[components.position], entity[components.box_collider]
  local collider_position = collision.get_collider_position(position, box_collider)

  local found_position, found_box_collider = found_entity[components.position], found_entity[components.box_collider]
  local found_collider_position = collision.get_collider_position(found_position, found_box_collider)
  local found_acceleration, found_velocity = found_entity[components.acceleration], found_entity[components.velocity]
  local rounded_found_collider_position = vector2(
    math.round(found_collider_position.x),
    math.round(found_collider_position.y)
  )
  local vector_direction = vector2(math.sign(found_velocity.x), math.sign(found_velocity.y))
  local slide_towards_tile = vector2(
    rounded_found_collider_position.x + vector_direction.x,
    rounded_found_collider_position.y
  )
  local moving_towards_tile = vector2(
    rounded_found_collider_position.x + vector_direction.x,
    rounded_found_collider_position.y + vector_direction.y
  )
  local direction = math.sign(slide_towards_tile.x - found_collider_position.x)
  local possible_colliders = self:find_at(moving_towards_tile,
    vector2.one(), set.create({ found_entity }))

  for possible_collider, _ in pairs(possible_colliders) do
    if possible_collider == entity and
        collision.overlap(collider_position, box_collider.size, moving_towards_tile, vector2.one()) then
      return false
    end
  end

  if math.abs(math.dist_vector(slide_towards_tile, found_collider_position) - 1) < 0.1 then
    found_velocity.x = 0
    found_position.x = math.round(found_position.x) - (found_entity[components.size].x - found_box_collider.size.x)
    self:update_collision_grid(found_entity)
    return true
  end

  found_velocity.x = found_velocity.x +
      ((direction * found_acceleration.speed) - (found_velocity.x * found_acceleration.friction)) * dt

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

      debug.gizmos.draw_rectangle(vector2(math.round(found_collider_position.x), math.round(found_collider_position.y)) *
        16, vector2.one() * 16, "fill", COLOR.RED)

      -- Checking the x velocity if it collides
      new_position = vector2(found_collider_position.x + found_velocity.x * dt, found_collider_position.y)
      if collision.overlap(collider_position, box_collider.size, new_position, found_box_collider.size) then
        if not try_round_position_y(self, entity, found_entity, dt) then
          found_velocity.x = 0
        end
      end

      -- Checking the y velocity if it collides
      new_position = vector2(found_collider_position.x, found_collider_position.y + found_velocity.y * dt)
      if collision.overlap(collider_position, box_collider.size, new_position, found_box_collider.size) then
        if not try_round_position_x(self, entity, found_entity, dt) then
          found_velocity.y = 0
        end

      end

      ::continue::
    end
  end, collision_query)
end)

return collision_system

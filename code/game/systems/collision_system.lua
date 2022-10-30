local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local utilities = require "code.engine.utilities"
local vector2 = require "code.engine.vector2"
local debug = require "code.engine.debug"
local world_grid = require "code.engine.world_grid"

local collision_filter = entity_query.filter(function(entity)
  return entity[components.box_collider] and entity[components.box_collider].enabled
end)

local collision_query = entity_query.all(components.position, components.size, components.box_collider,
  collision_filter())

-- Checks if the next tile the entity is moving towards is a collider
local function is_moving_towards_collider(self, collide_entity, found_entity, position, size, velocity)
  local vector_direction = vector2(math.clamp(-1, velocity.x, 1), math.clamp(-1, velocity.y, 1))
  local bottom_left = vector2(math.round(position.x), math.round((position.y + size.y - 1)))
  local moving_towards_tile = vector2(
    bottom_left.x + vector_direction.x,
    bottom_left.y + vector_direction.y
  )
  local possible_colliders = self:find_at(moving_towards_tile, vector2.one(), set.create({ found_entity }))

  for possible_wall, _ in pairs(possible_colliders) do
    if possible_wall == collide_entity then
      return true
    end
  end

  return false
end

local function try_round_position_y(collision_box_collider, position, size, acceleration, velocity, dt)
  local vector_direction = vector2(math.clamp(-1, velocity.x, 1), math.clamp(-1, velocity.y, 1))
  local bottom_left = vector2(math.round(position.x), math.round((position.y + size.y - 1)))
  local moving_towards_tile = vector2(
    bottom_left.x + vector_direction.x,
    bottom_left.y + vector_direction.y
  )

  local something = bottom_left.y - (position.y + size.y - 1)
  local direction = 0
  if something > 0 then
    direction = 1
  elseif something < 0 then
    direction = -1
  end

  if math.abs(something) > 0.4 then
    return
  end

  if math.abs(something) < 0.05 then
    position.y = math.round(position.y) - 0.25
  else
    velocity.y = velocity.y +
        ((direction * acceleration.speed) - (velocity.y * acceleration.friction)) * dt
  end


  debug.gizmos.draw_rectangle(moving_towards_tile * 16, vector2.one() * 16, "fill", COLOR.RED)
end

local function try_round_position_x(collision_box_collider, position, size, acceleration, velocity, dt)
  local vector_direction = vector2(math.clamp(-1, velocity.x, 1), math.clamp(-1, velocity.y, 1))
  local bottom_left = vector2(math.round(position.x), math.round((position.y)))
  local moving_towards_tile = vector2(
    bottom_left.x + vector_direction.x,
    bottom_left.y + vector_direction.y
  )

  local something = bottom_left.x - position.x
  local direction = 0
  if something > 0 then
    direction = 1
  elseif something < 0 then
    direction = -1
  end

  if math.abs(something) > 0.8 then
    return
  end

  print(something)

  if math.abs(something) < 0.05 then
    position.x = math.round(position.x)
  else
    velocity.x = velocity.x +
        ((direction * acceleration.speed) - (velocity.x * acceleration.friction)) * dt
  end


  debug.gizmos.draw_rectangle(moving_towards_tile * 16, vector2.one() * 16, "fill", COLOR.BLUE)
end

local collision_system = system(collision_query, function(self, dt)
  local collision_box_collider = nil
  local acceleration, position, size, velocity, found_entities, bottom_left = nil, nil, nil, nil, nil, nil

  self:for_each(function(entity)
    collision_box_collider = entity[components.box_collider]
    found_entities = self:find_near_entities(collision_box_collider.position, collision_box_collider.size * 1.25,
      set.create { entity })

    for found_entity, _ in pairs(found_entities) do
      acceleration, position, size, velocity = found_entity[components.acceleration], found_entity[components.position],
          found_entity[components.size],
          found_entity[components.velocity]
      bottom_left = vector2(position.x, position.y + size.y - 1)

      if not velocity then
        goto continue
      end

      -- Checking the x velocity if it collides
      if utilities.overlap(collision_box_collider.position, collision_box_collider.size,
        vector2(bottom_left.x + velocity.x * dt, bottom_left.y), vector2.one()) then
        try_round_position_y(collision_box_collider, position, size, acceleration, velocity, dt)
        if is_moving_towards_collider(self, entity, found_entity, position, size, vector2(velocity.x, 0)) then
          velocity.x = 0
        end
      end

      -- Checking the y velocity if it collides
      if utilities.overlap(collision_box_collider.position, collision_box_collider.size,
        vector2(bottom_left.x, bottom_left.y + velocity.y * dt), vector2.one()) then
        try_round_position_x(collision_box_collider, position, size, acceleration, velocity, dt)
        velocity.y = is_moving_towards_collider(self, entity, found_entity, position, size, vector2(0, velocity.y))
            and 0
            or velocity.y
      end

      ::continue::
    end
  end)
end)

return collision_system

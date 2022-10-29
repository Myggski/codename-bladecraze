local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local utilities = require "code.engine.utilities"
local vector2 = require "code.engine.vector2"

local collision_filter = entity_query.filter(function(entity)
  return entity[components.box_collider] and entity[components.box_collider].enabled
end)

local collision_query = entity_query.all(components.position, components.size, components.box_collider,
  collision_filter())

-- Checks if the next tile the entity is moving towards is a collider
local function is_moving_towards_collider(self, found_entity, position, size, velocity)
  local vector_direction = vector2(math.clamp(-1, velocity.x, 1), math.clamp(-1, velocity.y, 1))
  local center_position = utilities.get_center_position(position, size)
  local moving_towards_tile = vector2(
    math.floor(center_position.x) + vector_direction.x,
    math.floor(center_position.y) + vector_direction.y
  )
  local possible_colliders = self:find_at(moving_towards_tile, set.create({ found_entity }))
  local wall_collider = nil

  for possible_wall, _ in pairs(possible_colliders) do
    wall_collider = possible_wall[components.box_collider]
    if wall_collider and wall_collider.enabled then
      return true
    end
  end

  return false
end

local collision_system = system(collision_query, function(self, dt)
  local collision_box_collider = nil
  local position, size, velocity, found_entities = nil, nil, nil, nil

  self:for_each(function(entity)
    collision_box_collider = entity[components.box_collider]
    found_entities = self:find_near_entities(collision_box_collider.position, collision_box_collider.size * 1.25,
      set.create { entity })

    for found_entity, _ in pairs(found_entities) do
      position, size, velocity = found_entity[components.position], found_entity[components.size],
          found_entity[components.velocity]

      if not velocity then
        goto continue
      end

      -- Checking the x velocity if it collides
      if utilities.overlap(collision_box_collider.position, collision_box_collider.size,
        vector2(position.x + velocity.x * dt, position.y), size) then

        velocity.x = is_moving_towards_collider(self, found_entity, position, size, vector2(velocity.x, 0))
            and 0
            or velocity.x
      end

      -- Checking the y velocity if it collides
      if utilities.overlap(collision_box_collider.position, collision_box_collider.size,
        vector2(position.x, position.y + velocity.y * dt), size) then
        velocity.y = is_moving_towards_collider(self, found_entity, position, size, vector2(0, velocity.y))
            and 0
            or velocity.y
      end

      ::continue::
    end
  end)
end)

return collision_system

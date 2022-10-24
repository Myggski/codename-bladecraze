local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local world_grid = require "code.engine.world_grid"
local utilities = require "code.engine.utilities"
local vector2 = require "code.engine.vector2"

local movement_query = entity_query.all(
  components.position,
  components.size,
  components.velocity
).none(components.target_position)

local function find_nearby(self, entity, position, size)
  local nearby_entites = self:find_near_entities(position, size * 1.5, set.create { entity })

  for nearby_entity, _ in pairs(nearby_entites) do
    if nearby_entity[components.block] and
        utilities.overlap(position, size, nearby_entity[components.position], nearby_entity[components.size]) then

      return true
    end
  end

  return false
end

local function adjust_velocity_x(self, entity, position, size)
  if find_nearby(self, entity, position, size) then
    entity[components.velocity].x = 0
  end
end

local function adjust_velocity_y(self, entity, position, size)
  if find_nearby(self, entity, position, size) then
    entity[components.velocity].y = 0
  end
end

local movement_system = system(movement_query, function(self, dt)
  local position, size, velocity, previous_position = nil, nil, nil, nil

  self:for_each(function(entity)
    position = entity[components.position]
    size = entity[components.size]
    velocity = entity[components.velocity]
    
    position.x = position.x + velocity.x * dt
    position.y = position.y + velocity.y * dt

    if not (position == previous_position) then
      self:update_collision_grid(entity)
    end
  end)
end)

return movement_system

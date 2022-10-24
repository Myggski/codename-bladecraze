local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local utilities = require "code.engine.utilities"
local vector2 = require "code.engine.vector2"

local function handle_entity_collision(self, entity, block_position, block_size, dt)
  local position, size, velocity = nil, nil, nil
  local nearby_entites = self:find_near_entities(block_position, block_size * 1.25, set.create { entity })

  for nearby_entity, _ in pairs(nearby_entites) do
    position, size, velocity = nearby_entity[components.position], nearby_entity[components.size],
        nearby_entity[components.velocity]
    if velocity then
      if utilities.overlap(block_position, block_size, vector2(position.x + velocity.x * dt, position.y), size) then
        velocity.x = 0
      end

      if utilities.overlap(block_position, block_size, vector2(position.x, position.y + velocity.y * dt), size) then
        velocity.y = 0
      end
    end
  end
end

local block_filter = entity_query.filter(function(e)
  return e[components.block] == true
end)

local block_query = entity_query.all(components.position, components.size, components.block, block_filter())

local block_system = system(block_query, function(self, dt)
  self:for_each(function(entity)
    handle_entity_collision(self, entity, entity[components.position], entity[components.size], dt)
  end)
end)

return block_system

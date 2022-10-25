local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local utilities = require "code.engine.utilities"
local vector2 = require "code.engine.vector2"

local block_filter = entity_query.filter(function(entity)
  return entity[components.box_collider] and entity[components.box_collider].enabled
end)

local block_query = entity_query.all(components.position, components.size, components.block, block_filter())

local block_system = system(block_query, function(self, dt)
  local block_box_collider = nil
  local position, size, velocity, found_entities = nil, nil, nil, nil

  self:for_each(function(entity)
    block_box_collider = entity[components.box_collider]
    found_entities = self:find_near_entities(block_box_collider.position, block_box_collider.size * 1.25,
      set.create { entity })

    for entity, _ in pairs(found_entities) do
      position, size, velocity = entity[components.position], entity[components.size], entity[components.velocity]

      if not velocity then
        goto continue
      end

      -- TODO: Calculate where from point a (old position) to point b (new position) did the collision happend
      -- and reduce the velocity based on percentage, maybe
      if utilities.overlap(block_box_collider.position, block_box_collider.size,
        vector2(position.x + velocity.x * dt, position.y), size) then
        velocity.x = 0
      end

      if utilities.overlap(block_box_collider.position, block_box_collider.size,
        vector2(position.x, position.y + velocity.y * dt), size) then
        velocity.y = 0
      end

      ::continue::
    end
  end)
end)

return block_system

local components = require "code.engine.components"
local debug = require "code.engine.debug"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local vector2 = require "code.engine.vector2"
local world_grid = require "code.engine.world_grid"

local debug_query = entity_query.all(components.position)

local debug_draw_entities_system = system(debug_query, function(self, dt)
  local position, size = nil, nil

  self:for_each(function(entity)
    position = entity[components.position]
    position = world_grid:convert_to_world(position)
    size = world_grid:convert_to_world(vector2.one())
    debug.gizmos.draw_rectangle(position, size, nil, COLOR.WHITE, 1, 0)
  end)
end)

return debug_draw_entities_system

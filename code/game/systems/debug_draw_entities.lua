local components = require "code.engine.components"
local debug = require "code.engine.debug"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local vector2 = require "code.engine.vector2"

local debug_query = entity_query.all(components.position)

local debug_draw_entities_system = system(debug_query, function(self, dt)
  local position = nil

  self:for_each(function(entity)
    position = entity[components.position]

    debug.gizmos.draw_rectangle(_, position, vector2.one(), vector2.zero(), nil, dt)
  end)
end)

return debug_draw_entities_system

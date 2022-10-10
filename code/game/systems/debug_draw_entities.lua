local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"
local debug = require "code.utilities.debug"

local debug_query = entity_query.all(components.position)

local debug_draw_entities_system = system(debug_query, function(self, dt)
  local position = nil

  for _, entity in self:entity_iterator() do
    position = entity[components.position]

    debug.gizmos.draw_rectangle(_, position, { x = 1, y = 1 }, { x = 0, y = 0 }, nil, dt)
  end
end)

return debug_draw_entities_system

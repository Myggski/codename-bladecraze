local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"

local destroy_query = entity_query.all(components.destroy_timer)

local destroy_timer_system = system(destroy_query, function(self, dt)
  local destroy_timer = nil

  self:for_each(function(entity)
    destroy_timer = entity[components.destroy_timer]
    destroy_timer = destroy_timer - dt

    if destroy_timer <= 0 then
      entity:destroy()
    else
      entity[components.destroy_timer] = destroy_timer
    end
  end)
end)

return destroy_timer_system

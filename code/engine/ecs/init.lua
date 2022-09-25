local component = require "code.engine.ecs.component"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local world = require "code.engine.ecs.world"

local ecs = {
  component = component,
  entity_query = entity_query,
  system = system,
  world = world,
}

return ecs

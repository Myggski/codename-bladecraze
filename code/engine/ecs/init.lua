local archetype = require "code.engine.ecs.archetype"
local component = require "code.engine.ecs.component"
local entity = require "code.engine.ecs.entity"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local world = require "code.engine.ecs.world"

local ecs = {
  archetype = archetype,
  component = component,
  entity = entity,
  entity_query = entity_query,
  system = system,
  world = world,
}

return ecs

local component = require "code.engine.ecs.component"
local filter = require "code.engine.ecs.filter"
local system = require "code.engine.ecs.system"
local world = require "code.engine.ecs.world"

local ecs = {
  component = component,
  filter = filter,
  system = system,
  world = world,
}

return ecs

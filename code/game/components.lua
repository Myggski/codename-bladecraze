local component = require "code.engine.ecs.component"

local position_component = component({ x = -9999, y = -9999 })
local size_component = component({ x = 1, y = 1 })
local rotation_component = component(0) -- Radian?
local acceleration_component = component({ x = 0, y = 0 })
local speed_component = component(0)
local aim_direction_component = component({ x = 0, y = 0 })
local object_pool_component = component(1000) -- Number of entites to pre-spawn
local sprite_component = component("") -- Url to static image?
local animation_component = component({
  sprite_sheet = nil,
  quads = {},
  current_time = 0,
  duration = 0,
})
local input_component = component({
  player = 1, -- 1 == player 1, 2 == player 2
  controller = "keyboard" or "gamepad",
  movement_direction = { x = 0, y = 0 },
  aim_direction = { x = 0, y = 0 },
  action = PLAYER.ACTIONS.NONE,
})

_G.components = {
  position = position_component,
  size = size_component,
  rotation = rotation_component,
  acceleration = acceleration_component,
  speed = speed_component,
  aim_direction = aim_direction_component,
  object_pool = object_pool_component,
  sprite = sprite_component,
  animation = animation_component,
  input = input_component,
}

return _G.components

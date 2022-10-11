local component = require "code.engine.ecs.component"

local acceleration_component = component({ x = 0, y = 0 })
local animation_component = component({
  current_animation_state = ANIMATION_STATE_TYPES.IDLE,
  direction = 1,
  [ANIMATION_STATE_TYPES.IDLE] = nil,
  [ANIMATION_STATE_TYPES.WALKING] = nil,
  [ANIMATION_STATE_TYPES.DEAD] = nil,
})
local input_component = component({
  player = 1, -- 1 == player 1, 2 == player 2
  controller = "keyboard" or "gamepad",
  enabled = true,
  movement_direction = { x = 0, y = 0 },
  aim_direction = { x = 0, y = 0 },
  action = PLAYER.ACTIONS.NONE,
})
local health_component = component(1)
local object_pool_component = component(1000) -- Number of entites to pre-spawn
local position_component = component({ x = -9999, y = -9999 })
local rotation_component = component(0) -- Radian?
local size_component = component({ x = 1, y = 1 })
local speed_component = component(0)
local sprite_component = component("") -- Url to static image?

_G.components = {
  acceleration = acceleration_component,
  animation = animation_component,
  input = input_component,
  health = health_component,
  object_pool = object_pool_component,
  position = position_component,
  rotation = rotation_component,
  size = size_component,
  speed = speed_component,
  sprite = sprite_component,
}

return _G.components

local component = require "code.engine.ecs.component"

local acceleration_component = component({ x = 0, y = 0 })
local animation_component = component({
  animations = {
    [ANIMATION_STATE_TYPES.IDLE] = {
      spritesheet = "spritesheet_for_idle.png",
      stay_at_endframe = false
    },
    [ANIMATION_STATE_TYPES.WALKING] = {
      spritesheet = "spritesheet_for_walking.png",
      stay_at_endframe = false
    },
    [ANIMATION_STATE_TYPES.DEAD] = {
      spritesheet = "spritesheet_for_dead.png",
      stay_at_endframe = true
    }
  },
  current_animation_state = ANIMATION_STATE_TYPES.IDLE,
  current_time = 0,
  duration = 0,
  quads = {},
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

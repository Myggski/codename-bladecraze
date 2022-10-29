-- All the componets with their default values in the game, that the systems will use to get values
local component = require "code.engine.ecs.component"
local vector2 = require "code.engine.vector2"

local acceleration_component = component({
  speed = 10,
  friction = 5,
})
local animation_component = component({
  current_animation_state = ANIMATION_STATE_TYPES.IDLE,
  direction = 1,
  [ANIMATION_STATE_TYPES.IDLE] = nil,
  [ANIMATION_STATE_TYPES.WALKING] = nil,
  [ANIMATION_STATE_TYPES.DEAD] = nil,
})
local box_collider_component = component({
  enabled = true,
  position = vector2.one(),
  size = vector2.one(),
}) -- if true -> block movement, if false -> blockage is disabled
local input_component = component({
  player = 1, -- 1 == player 1, 2 == player 2
  controller = "keyboard" or "gamepad",
  enabled = true,
  movement_direction = vector2.zero(),
  aim_direction = vector2.zero(),
  action = PLAYER.ACTIONS.NONE,
})
local health_component = component(1)
local player_data_component = component({ player_id = -1, controller_type = CONTROLLER_TYPES.GAMEPAD })
local object_pool_component = component(1000) -- Number of entites to pre-spawn
local position_component = component()
local rotation_component = component(0) -- Radian?
local size_component = component(vector2.one())
local sprite_component = component({ texture = nil, quad = nil }) -- Url to static image?
local target_position_component = component(vector2.zero())
local velocity_component = component(vector2.zero())

return {
  acceleration = acceleration_component,
  animation = animation_component,
  box_collider = box_collider_component,
  input = input_component,
  health = health_component,
  object_pool = object_pool_component,
  player_data = player_data_component,
  position = position_component,
  rotation = rotation_component,
  size = size_component,
  sprite = sprite_component,
  target_position = target_position_component,
  velocity = velocity_component,
}

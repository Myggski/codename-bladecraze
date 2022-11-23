-- All the componets with their default values in the game, that the systems will use to get values
local component = require "code.engine.ecs.component"
local vector2 = require "code.engine.vector2"
local data = require "code.game.entities.powerups.powerup_data"
local keys = data.UPGRADE_KEYS

local acceleration_component = component({
  speed = 10,
  friction = 5,
})
local animation_component = component({
  z_index = 0,
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
})
local damager_component = component(1)
local destroy_timer_component = component(2)
local explosion_radius_component = component(2)
local input_component = component({
  player_id = 1, -- 1 == player 1, 2 == player 2
  controller = "keyboard" or "gamepad",
  enabled = true,
  movement_direction = vector2.zero(),
  aim_direction = vector2.zero(),
  action = PLAYER.ACTIONS.NONE,
})
local health_component = component(1)
local player_data_component = component({ player_id = -1, controller_type = CONTROLLER_TYPES.GAMEPAD })
local player_stats_component = component({
  explosion_duration = 2,
  bomb_spawn_delay = 0.1,
  [keys.BOMB_RADIUS] = 1, -- Center and 1 neighbor
  [keys.BOMBS] = 1,
  [keys.SPEED] = 200
})
local object_pool_component = component(1000) -- Number of entites to pre-spawn
local position_component = component()
local rotation_component = component(0) -- Radian?
local size_component = component(vector2.one())
local sprite_component = component({ z_index = 0, texture = nil, quad = nil }) -- Url to static image?
local target_position_component = component(vector2.zero())
local velocity_component = component(vector2.zero())

return {
  acceleration = acceleration_component,
  animation = animation_component,
  box_collider = box_collider_component,
  damager = damager_component,
  destroy_timer = destroy_timer_component,
  explosion_radius = explosion_radius_component,
  input = input_component,
  health = health_component,
  object_pool = object_pool_component,
  player_data = player_data_component,
  player_stats = player_stats_component,
  position = position_component,
  rotation = rotation_component,
  size = size_component,
  sprite = sprite_component,
  target_position = target_position_component,
  velocity = velocity_component,
}

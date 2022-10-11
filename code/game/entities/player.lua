local asset_manager = require "code.engine.asset_manager"
local animations = require "code.engine.animations"

local function create_player(world, player_id, start_position)
  local idle = asset_manager:get_image("player/player_idle_" .. player_id .. ".png")
  local walk = asset_manager:get_image("player/player_run_" .. player_id .. ".png")
  local dead = asset_manager:get_image("player/player_dead_" .. player_id .. ".png")

  world:entity(
    components.position(start_position),
    components.size({ x = 1, y = 1 }),
    components.acceleration(),
    components.speed(24),
    components.input(),
    components.health(1),
    components.animation({
      current_animation_state = ANIMATION_STATE_TYPES.IDLE,
      freeze_frame = false,
      [ANIMATION_STATE_TYPES.IDLE] = animations.new_animation(idle, { 0, 0, 16, 20, 6 }, 0.6),
      [ANIMATION_STATE_TYPES.WALKING] = animations.new_animation(walk, { 0, 0, 16, 22, 8 }, 0.8),
      [ANIMATION_STATE_TYPES.DEAD] = animations.new_animation(dead, { 0, 0, 16, 20, 14 }, 1.4),
    })
  )
end

return create_player

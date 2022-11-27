local animations = require "code.engine.animations"
local archetype = require "code.engine.ecs.archetype"
local asset_manager = require "code.engine.asset_manager"
local components = require "code.engine.components"
local vector2 = require "code.engine.vector2"

local player_archetype = archetype.setup(components.position,
  components.size,
  components.velocity,
  components.acceleration,
  components.input,
  components.health,
  components.animation,
  components.player_stats,
  components.box_collider
)

local function create_player(world, player_id, position, z_index)
  local idle = asset_manager:get_image("player/player_idle_" .. player_id .. ".png")
  local walk = asset_manager:get_image("player/player_run_" .. player_id .. ".png")
  local dead = asset_manager:get_image("player/player_dead_" .. player_id .. ".png")

  local player = world:entity(
    components.position(position),
    components.size(vector2(1, 1.375)),
    components.velocity(),
    components.acceleration({
      speed = 200,
      friction = 30,
    }),
    components.input(),
    components.health(1),
    components.player_stats(),
    components.animation({
      z_index = 100 + z_index + GAME.MAX_PLAYERS - player_id,
      current_animation_state = ANIMATION_STATE_TYPES.IDLE,
      freeze_frame = false,
      [ANIMATION_STATE_TYPES.IDLE] = animations.new_animation(idle, { 0, 0, 16, 22, 6 }, 0.6),
      [ANIMATION_STATE_TYPES.WALKING] = animations.new_animation(walk, { 0, 0, 16, 22, 8 }, 0.8),
      [ANIMATION_STATE_TYPES.DEAD] = animations.new_animation(dead, { 0, 0, 17, 22, 14 }, 1.4),
    }),
    components.box_collider({
      enabled = true,
      offset = vector2(0, 0.375),
      size = vector2.one(),
      ignore = set.create({ player_archetype })
    })
  )

  player[components.input].player_id = player_id

  return player
end

return setmetatable({
  create = create_player,
  get_archetype = function() return player_archetype end,
}, { __call = function(_, ...) return create_player(...) end })

local animations = require "code.engine.animations"
local archetype = require "code.engine.ecs.archetype"
local asset_manager = require "code.engine.asset_manager"
local components = require "code.engine.components"
local vector2 = require "code.engine.vector2"

local bomb_archetype = archetype.setup(
  components.animation,
  components.box_collider,
  components.destroy_timer,
  components.explosion_radius,
  components.health,
  components.player_stats,
  components.position,
  components.size
)

local function create_bomb(world, position, player_stats)
  local idle = asset_manager:get_image("bomb/bomb.png")

  return world:entity(
    components.health(1),
    components.player_stats(player_stats),
    components.destroy_timer(player_stats.explosion_duration),
    components.explosion_radius(player_stats.bomb_radius),
    components.position(position),
    components.size(vector2.one()),
    components.box_collider({
      enabled = true,
      offset = vector2.zero(),
      size = vector2.one(),
    }),
    components.animation({
      z_index = 0,
      current_animation_state = ANIMATION_STATE_TYPES.IDLE,
      [ANIMATION_STATE_TYPES.IDLE] = animations.new_animation(idle,
        { 0, 0, 16, 16, 4 }
        , 0.6),
    })
  )
end

return setmetatable({
  create = create_bomb,
  get_archetype = function() return bomb_archetype end,
}, { __call = function(_, ...) return create_bomb(...) end })

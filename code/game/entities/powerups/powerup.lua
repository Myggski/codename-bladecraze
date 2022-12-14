local animations = require "code.engine.animations"
local archetype = require "code.engine.ecs.archetype"
local asset_manager = require "code.engine.asset_manager"
local components = require "code.engine.components"
local vector2 = require "code.engine.vector2"

local powerup_archetype = archetype.setup(
  components.animation,
  components.box_collider,
  components.player_stats,
  components.position,
  components.health,
  components.size
)

local function create_powerup(world, position, data)
  local idle = asset_manager:get_image("powerup/powerups.png")
  local spawn_position = vector2(math.round(position.x), math.round(position.y))

  return world:entity(
    components.box_collider({
      enabled = false, -- Trigger collision
      offset = vector2(0.3, 0.3),
      size = vector2(0.4, 0.4),
    }),
    components.player_stats(data.stats),
    components.position(spawn_position),
    components.health(1),
    components.size(vector2.one()),
    components.animation({
      z_index = -1000,
      current_animation_state = ANIMATION_STATE_TYPES.IDLE,
      [ANIMATION_STATE_TYPES.IDLE] = animations.new_animation(idle,
        data.animation_data,
        0.8)
    })
  )
end

return setmetatable({
  create = create_powerup,
  get_archetype = function() return powerup_archetype end,
}, { __call = function(_, ...) return create_powerup(...) end })

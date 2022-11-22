local animations = require "code.engine.animations"
local archetype = require "code.engine.ecs.archetype"
local asset_manager = require "code.engine.asset_manager"
local components = require "code.engine.components"
local vector2 = require "code.engine.vector2"
-- local data = require "code.game.powerups.powerup_data"

local powerup_archetype = archetype.setup(
  components.animation,
  components.box_collider,
  components.size,
  components.position
)

local function create_powerup(world, position)
  local idle = asset_manager:get_image("powerup/powerups.png")
  local spawn_position = vector2(math.round(position.x), math.round(position.y))
  return world:entity(
    components.box_collider({
      enabled = false, -- Trigger collision
      offset = vector2(0, 0),
      size = vector2(1, 1.5),
    }),
    components.position(spawn_position),
    components.size(vector2.one()),
    components.animation({
      z_index = -1000,
      current_animation_state = ANIMATION_STATE_TYPES.IDLE,
      [ANIMATION_STATE_TYPES.IDLE] = animations.new_animation(idle,
        { 0, 0, 16, 24, 1 }
        , 0.8),
    })
  )
end

return setmetatable({
  create = create_powerup,
  get_archetype = function() return powerup_archetype end,
}, { __call = function(_, ...) return create_powerup(...) end })

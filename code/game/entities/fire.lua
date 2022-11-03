local animations = require "code.engine.animations"
local archetype = require "code.engine.ecs.archetype"
local asset_manager = require "code.engine.asset_manager"
local components = require "code.engine.components"
local vector2 = require "code.engine.vector2"

local fire_archetype = archetype.setup(
  components.animation,
  components.box_collider,
  components.damager,
  components.destroy_timer,
  components.size,
  components.position
)

local function create_fire(world, position)
  local idle = asset_manager:get_image("bomb/bomb_fire.png")
  local spawn_position = vector2(math.round(position.x), math.round(position.y))

  return world:entity(
    components.box_collider({
      enabled = false, -- Trigger collision
      offset = vector2(0.3, 0.3),
      size = vector2(0.4, 0.4),
    }),
    components.damager(),
    components.destroy_timer(1),
    components.position(spawn_position),
    components.size(vector2.one()),
    components.animation({
      z_index = -1000,
      current_animation_state = ANIMATION_STATE_TYPES.IDLE,
      [ANIMATION_STATE_TYPES.IDLE] = animations.new_animation(idle,
        { 0, 0, 16, 16, 8 }
        , 0.8),
    })
  )
end

return setmetatable({
  create = create_fire,
  get_archetype = function() return fire_archetype end,
}, { __call = function(_, ...) return create_fire(...) end })

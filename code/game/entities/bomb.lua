local animations = require "code.engine.animations"
local archetype = require "code.engine.ecs.archetype"
local asset_manager = require "code.engine.asset_manager"
local components = require "code.engine.components"
local vector2 = require "code.engine.vector2"

local bomb_archetype = archetype.setup(
  components.animation,
  components.box_collider,
  components.position,
  components.size
)

local function create_bomb(world, position)
  local idle = asset_manager:get_image("bomb/bomb.png")
  local spawn_position = vector2(math.round(position.x), math.round(position.y))

  return world:entity(
    components.position(spawn_position),
    components.size(vector2.one()),
    components.box_collider({
      enabled = true,
      position = spawn_position,
      size = vector2.one()
    }),
    components.animation({
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

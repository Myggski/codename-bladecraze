local animations = require "code.engine.animations"
local archetype = require "code.engine.ecs.archetype"
local asset_manager = require "code.engine.asset_manager"
local player_input = require "code.player.player_input"

local bubble_controller_archetype = archetype.setup(
  components.acceleration,
  components.animation,
  components.player_data,
  components.position,
  components.size,
  components.target_position
)

local function create_bubble_controller(world, player_id, controller_type, position)
  local idle = player_input.is_gamepad(controller_type)
      and asset_manager:get_image("bubble_gamepad.png")
      or asset_manager:get_image("bubble_keyboard.png")

  return world:entity(
    components.acceleration({
      speed = 20,
      friction = 0,
    }),
    components.position(position),
    components.target_position(position),
    components.player_data({ player_id = player_id, controller_type = controller_type }),
    components.size({ x = 2, y = 3 }),
    components.animation({
      current_animation_state = ANIMATION_STATE_TYPES.IDLE,
      [ANIMATION_STATE_TYPES.IDLE] = animations.new_animation(idle,
        { 0, 0, 32, 48, 8 }
        , 1.6),
    })
  )
end

return setmetatable({
  create = create_bubble_controller,
  get_archetype = function() return bubble_controller_archetype end,
}, { __call = function(_, ...) return create_bubble_controller(...) end })

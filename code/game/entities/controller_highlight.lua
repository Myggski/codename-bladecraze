local animations = require "code.engine.animations"
local archetype = require "code.engine.ecs.archetype"
local asset_manager = require "code.engine.asset_manager"

local controller_hightlight_archetype = archetype.setup(
  components.animation,
  components.list_index,
  components.position,
  components.size
)

local function create_controller_highlight(world, player_id, controller_type, position)
  local idle = asset_manager:get_image("level/controller.png")

  return world:entity(
    components.position(position),
    components.player_data({ player_id = player_id, controller_type = controller_type }),
    components.size({ x = 1, y = 1 }),
    components.animation({
      current_animation_state = ANIMATION_STATE_TYPES.IDLE,
      freeze_frame = true,
      [ANIMATION_STATE_TYPES.IDLE] = animations.new_animation(idle,
        { 0, 0, 16, 16, 10 }
        , 1),
    })
  )
end

return setmetatable({
  create = create_controller_highlight,
  get_archetype = function() return controller_hightlight_archetype end,
}, { __call = function(_, ...) return create_controller_highlight(...) end })

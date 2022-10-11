local asset_manager = require "code.engine.asset_manager"
local animations = require "code.engine.animations"

local function create_wall(world, wall_id, start_position)
  local idle = asset_manager:get_image("level/walls.png")
  local offset_x = wall_id * 16

  world:entity(
    components.position(start_position),
    components.size({ x = 1, y = 1 }),
    components.health(wall_id == 0 and 20 or 1),
    components.animation({
      current_animation_state = ANIMATION_STATE_TYPES.IDLE,
      freeze_frame = true,
      [ANIMATION_STATE_TYPES.IDLE] = animations.new_animation(idle, { offset_x, 0, 16, 22, 1 }, 0),
    })
  )
end

return create_wall

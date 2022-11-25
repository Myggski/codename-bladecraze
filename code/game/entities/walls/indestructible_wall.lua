local archetype = require "code.engine.ecs.archetype"
local components = require "code.engine.components"
local vector2 = require "code.engine.vector2"

local indestructible_wall_archetype = archetype.setup(
  components.animation,
  components.box_collider,
  components.position,
  components.size
)

local function create_indestructible_wall(world, start_position, wall_animation)
  return world:entity(
    components.animation({
      z_index = MIN_Z_INDEX,
      current_animation_state = ANIMATION_STATE_TYPES.IDLE,
      freeze_frame = true,
      [ANIMATION_STATE_TYPES.IDLE] = wall_animation,
    }),
    components.box_collider({
      enabled = true,
      offset = vector2.zero(),
      size = vector2.one()
    }),
    components.position(start_position),
    components.size(vector2(1, 1.5))
  )
end

return {
  create = create_indestructible_wall,
  get_archetype = function() return indestructible_wall_archetype end
}

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
    components.size(vector2(1, 1.375))
  )
end

return {
  create = create_indestructible_wall,
  archetype = indestructible_wall_archetype,
}

local archetype = require "code.engine.ecs.archetype"

local indestructible_wall_archetype = archetype.setup(
  components.animation,
  components.block,
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
    components.block(),
    components.position(start_position),
    components.size({ x = 1, y = 1 })
  )
end

return {
  create = create_indestructible_wall,
  archetype = indestructible_wall_archetype,
}

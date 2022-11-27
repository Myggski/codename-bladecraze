local archetype = require "code.engine.ecs.archetype"
local components = require "code.engine.components"
local vector2 = require "code.engine.vector2"

local destructible_wall_archetype = archetype.setup(
  components.animation,
  components.box_collider,
  components.health,
  components.position,
  components.size
)

local function create_destructible_wall(world, start_position, wall_animation)
  local death_animation = wall_animation
  death_animation.duration = 0.6 -- fire destroy_timer - TODO: Create a variable

  return world:entity(
    components.animation({
      z_index = MIN_Z_INDEX + 1,
      current_animation_state = ANIMATION_STATE_TYPES.IDLE,
      freeze_frame = true,
      [ANIMATION_STATE_TYPES.IDLE] = wall_animation,
      [ANIMATION_STATE_TYPES.DEAD] = death_animation,
    }),
    components.box_collider({
      enabled = true,
      offset = vector2.zero(),
      size = vector2.one()
    }),
    components.health(1),
    components.position(start_position),
    components.size(vector2(1, 1.5))
  )
end

return {
  create = create_destructible_wall,
  get_archetype = function() return destructible_wall_archetype end
}

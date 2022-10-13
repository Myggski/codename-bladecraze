local archetype = require "code.engine.ecs.archetype"
local asset_manager = require "code.engine.asset_manager"

local background_image_archetype = archetype.setup(
  components.size,
  components.sprite,
  components.position
)

local function create_background_image(world, sprite_url, position)
  local sprite = asset_manager:get_image(sprite_url)

  return world:entity(
    components.size({ x = 0, y = 0 }),
    components.sprite(sprite),
    components.position(position)
  )
end

return setmetatable({
  create = create_background_image,
  get_archetype = function() return background_image_archetype end,
}, { __call = function(_, ...) return create_background_image(...) end })

local archetype = require "code.engine.ecs.archetype"
local asset_manager = require "code.engine.asset_manager"
local components = require "code.engine.components"
local vector2 = require "code.engine.vector2"

local background_image_archetype = archetype.setup(
  components.size,
  components.sprite,
  components.position
)

local function create_background_image(world, sprite_url, position)
  local texture = asset_manager:get_image(sprite_url)
  local width, height = texture:getDimensions()

  return world:entity(
    components.size(vector2.zero()),
    components.sprite({
      z_index = 0,
      texture = texture,
      quad = love.graphics.newQuad(0, 0, width, height, texture),
    }),
    components.position(position)
  )
end

return setmetatable({
  create = create_background_image,
  get_archetype = function() return background_image_archetype end,
}, { __call = function(_, ...) return create_background_image(...) end })

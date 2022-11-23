local asset_manager = require "code.engine.asset_manager"
local animations = require "code.engine.animations"
local destructible_wall = require "code.game.entities.walls.destructible_wall"
local indestructible_wall = require "code.game.entities.walls.indestructible_wall"

local function create_wall(world, wall_id, level_id, start_position)
  local y_offset = level_id * 24
  local wall_animation = animations.new_animation(
    asset_manager:get_image("level/walls.png"),
    { wall_id * 16, y_offset, 16, 24, 1 },
    0
  )

  if wall_id >= 1 and wall_id <= 3 then
    return destructible_wall.create(world, start_position, wall_animation)
  elseif wall_id == 0 then
    return indestructible_wall.create(world, start_position, wall_animation)
  end
end

local function get_archetype(wall_id)
  if wall_id >= 1 and wall_id <= 3 then
    return destructible_wall.archetype
  elseif wall_id == 0 then
    return indestructible_wall.archetype
  end
end

return setmetatable({
  create = create_wall,
  get_archetype = get_archetype,
}, { __call = function(_, ...) return create_wall(...) end })

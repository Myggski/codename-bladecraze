local asset_manager = require "code.engine.asset_manager"
local animations = require "code.engine.animations"
local create_destructible_wall = require "code.game.entities.wall.create_destructible_wall"
local create_indestructible_wall = require "code.game.entities.wall.create_indestructible_wall"

local function create_wall(world, wall_id, level_type, start_position)
  local wall_animation = animations.new_animation(
    asset_manager:get_image("level/walls.png"),
    { wall_id * 16, 0, 16, 22, 1 },
    0
  )

  if wall_id >= 1 and wall_id <= 3 then
    create_destructible_wall(world, start_position, wall_animation)
  elseif wall_id == 0 then
    create_indestructible_wall(world, start_position, wall_animation)
  end
end

return create_wall

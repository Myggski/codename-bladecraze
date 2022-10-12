local asset_manager = require "code.engine.asset_manager"
local animations = require "code.engine.animations"
local create_destructable_wall = require "code.game.entities.wall.create_destructable_wall"
local create_indestructable_wall = require "code.game.entities.wall.create_indestructable_wall"

local function create_wall(world, wall_id, start_position)
  local wall_animation = animations.new_animation(
    asset_manager:get_image("level/walls.png"),
    { wall_id * 16, 0, 16, 22, 1 },
    0
  )

  if wall_id >= 1 and wall_id <= 3 then
    create_destructable_wall(world, start_position, wall_animation)
  elseif wall_id == 0 then
    create_indestructable_wall(world, start_position, wall_animation)
  end
end

return create_wall

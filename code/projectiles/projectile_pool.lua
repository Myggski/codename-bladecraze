local projectile = require("code.projectiles.projectile")

local projectile_pool = {}
local grid = nil
local sprite_sheet = nil
function projectile_pool:create(image, type, count, entity_grid)
  grid = entity_grid
  if sprite_sheet == nil then
    sprite_sheet = image
  end
  if projectile_pool[type] == nil then
    projectile_pool[type] = { current_index = 1, count = count, list = {} }
    for i = 1, count do
      table.insert(projectile_pool[type].list, projectile:create(sprite_sheet, grid, type, projectile_pool[type].list))
    end
  end
end
function projectile_pool:get_projectile(type)
  if (projectile_pool[type] == nil) then
    print("could not get projectile: type not found")
    return
  end

  local count = #projectile_pool[type].list
  if count == 0 then
    return nil
  end
  local instance = table.remove(projectile_pool[type].list, count)
  instance:activate()

  return instance
end

return projectile_pool

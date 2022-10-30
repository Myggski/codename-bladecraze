local camera = require "code.engine.camera"
local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local world_grid = require "code.engine.world_grid"

local camera_filter = entity_query.filter(function(e)
  return camera:is_outside_camera_view(e[components.position], e[components.size])
end)

local draw_query = entity_query
    .all(components.position, components.size)
    .any(components.animation, components.sprite)
    .none(camera_filter())

local y_sort = function(a, b) return a.y < b.y end
local z_sort = function(a, b) return a.z_index < b.z_index end

--[[
  a binary search for group based on y
]]
function find_group(t, y, low, high)
  if low > high then
    return -1
  else
    mid = math.floor((low + high) / 2)
    if y == t[mid].y then
      return mid
    elseif y > t[mid].y then --x is on the right side
      return find_group(t, y, mid + 1, high)
    else -- x is on the left side
      return find_group(t, y, low, mid - 1)
    end
  end
end

local entity_draw = system(draw_query, function(self)
  local animation, position, size, sprite, current_animation = nil, nil, nil, nil, nil
  --[[
    draw_arr contains elements with a y_position and group of entities in that position
    each group of entities contain pairs of z_index and matching entity
  ]]
  local draw_arr = {}
  self:for_each(function(entity)
    animation = entity[components.animation]
    position = entity[components.position]
    sprite = entity[components.sprite]

    local comp = animation or sprite
    local z_index = comp.z_index
    local y_pos = math.floor(position.y)

    --find group in array based on y position
    local table_pos = find_group(draw_arr, y_pos, 1, #draw_arr)
    if table_pos == -1 then
      table_pos = table.binary_insert(draw_arr, { y = y_pos, group = {} }, y_sort)
    end

    --store entity in group based on z_index
    local group = draw_arr[table_pos].group
    table.binary_insert(group, { z_index = z_index, entity = entity }, z_sort)
  end)

  for i = 1, #draw_arr do
    --objects with highest z_index should be drawn first, lower z_index is drawn on top
    for j = #draw_arr[i].group, 1, -1 do

      local entity = draw_arr[i].group[j].entity
      animation = entity[components.animation]
      position = entity[components.position]
      size = entity[components.size]
      sprite = entity[components.sprite]
      if animation then
        current_animation = animation[animation.current_animation_state]
        love.graphics.draw(
          current_animation.texture,
          current_animation.current_quad,
          world_grid:convert_to_world(position.x + size.x * 0.5),
          world_grid:convert_to_world(position.y + size.y * 0.5),
          0,
          animation.direction,
          1,
          current_animation.viewport.x * 0.5,
          current_animation.viewport.y * 0.5
        )
      elseif sprite then
        love.graphics.draw(
          sprite.texture,
          world_grid:convert_to_world(position.x + size.x * 0.5),
          world_grid:convert_to_world(position.y + size.y * 0.5)
        )
      end
    end
  end
end)

return entity_draw

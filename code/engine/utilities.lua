local vector2 = require "code.engine.vector2"

local function is_inside(...)
  local position, size, x, y = ...
  return position.x <= x and position.y <= y and (position.x + size.w) >= x and (position.y + size.h) >= y
end

local function get_center_position(...)
  local position, size = ...

  return vector2(position.x + size.x * 0.5, position.y + size.y * 0.5)
end

local function overlap(position_a, size_a, position_b, size_b)
  local center_a = get_center_position(position_a, size_a)
  local center_b = get_center_position(position_b, size_b)

  return (
      center_a.x <= center_b.x + size_b.x and
          center_a.x + size_a.x >= center_b.x and
          center_a.y <= center_b.y + size_b.y and
          center_a.y + size_a.y >= center_b.y
      )
end

local function collision_direction(center1, center2)
  local dir_x, dir_y = math.normalize(
    center2.x - center1.x,
    center2.y - center1.y
  )
  local vertical_dot = math.dot(0, -1, dir_x, dir_y) -- top och bottom
  local horizontal_dot = math.dot(-1, 0, dir_x, dir_y) -- left or right

  if math.abs(vertical_dot) > math.abs(horizontal_dot) then
    return vertical_dot > 0 and vector2.up() or vector2.down()
  else
    return horizontal_dot > 0 and vector2.left() or vector2.right()
  end
end

return {
  collision_direction = collision_direction,
  is_inside = is_inside,
  get_center_position = get_center_position,
  overlap = overlap
}

local vector2 = require "code.engine.vector2"

local function is_inside(x, y, position, size)
  return position.x <= x and position.y <= y and (position.x + size.x) >= x and (position.y + size.y) >= y
end

local function get_center_position(position, size)
  return vector2(position.x + (size.x * 0.5), position.y + (size.y * 0.5))
end

return {
  is_inside = is_inside,
  get_center_position = get_center_position,
}

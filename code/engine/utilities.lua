local vector2 = require "code.engine.vector2"
local gizmos = require "code.engine.debug.gizmos"

local function is_inside(...)
  local position, size, x, y = ...
  return position.x <= x and position.y <= y and (position.x + size.w) >= x and (position.y + size.h) >= y
end

local function get_center_position(...)
  local position, size = ...

  return vector2(position.x + (size.x * 0.5), position.y + (size.y * 0.5))
end

local function overlap(position_a, size_a, position_b, size_b)
  return (
      position_a.x <= position_b.x + size_b.x and
          position_a.x + size_a.x >= position_b.x and
          position_a.y <= position_b.y + size_b.y and
          position_a.y + size_a.y >= position_b.y
      )
end

return {
  is_inside = is_inside,
  get_center_position = get_center_position,
  overlap = overlap
}

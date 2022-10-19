local function is_inside(...)
  local position, size, x, y = ...
  return position.x <= x and position.y <= y and (position.x + size.w) >= x and (position.y + size.h) >= y
end

local function get_center_position(...)
  local position, size = ...

  return position.x + size.x * 0.5, position.y + size.y * 0.5
end

return {
  is_inside = is_inside,
  get_center_position = get_center_position
}
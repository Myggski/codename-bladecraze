local function get_center_position(position, size)
  position = position or { x = 0, y = 0 }
  size = size or { x = 0, y = 0 }

  return { x = position.x + size.x * 0.5, y = position.y + size.y * 0.5 }
end

_G.get_center_position = get_center_position

local function get_center_position(position, size)
  if not position or not size then
    return { x = 0, y = 0 }
  end

  return { x = position.x + size.x * 0.5, y = position.y + size.y * 0.5 }
end

_G.get_center_position = get_center_position

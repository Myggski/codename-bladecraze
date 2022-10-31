local function get_collider_position(position, box_collider)
  return position + box_collider.offset
end

local function overlap(position_a, size_a, position_b, size_b)
  return (
      position_a.x < position_b.x + size_b.x and
          position_a.x + size_a.x > position_b.x and
          position_a.y < position_b.y + size_b.y and
          position_a.y + size_a.y > position_b.y
      )
end

return {
  get_collider_position = get_collider_position,
  overlap = overlap
}

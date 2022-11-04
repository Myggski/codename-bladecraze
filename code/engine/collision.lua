local function get_collider_position(position, box_collider)
  return position + box_collider.offset
end

-- Is checking if the entity is touching it pixel perfectly, but also overlapping
local function is_touching(position_a, size_a, position_b, size_b)
  return (
      position_a.x <= position_b.x + size_b.x and
          position_a.x + size_a.x >= position_b.x and
          position_a.y <= position_b.y + size_b.y and
          position_a.y + size_a.y >= position_b.y
      )
end

-- Is checking of entity A is inside entity B
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
  is_touching = is_touching,
  overlap = overlap
}

local world_grid = {
  unit_size = 16,
}

world_grid.__index = world_grid

function world_grid:convert_to_world(grid)
  return grid * self.unit_size
end

function world_grid:convert_to_grid(world)
  return world / self.unit_size
end

function world_grid:world_to_grid(world_x, world_y)
  return self:convert_to_grid(world_x), self:convert_to_grid(world_y)
end

function world_grid:grid_to_world(...)
  local args = { ... }
  for key, value in ipairs(args) do
    args[key] = self:convert_to_world(value)
  end
  return unpack(args)
end

return world_grid

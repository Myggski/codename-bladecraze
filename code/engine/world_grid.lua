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

function world_grid:world_to_grid(...)
  local args = { ... }
  for key, value in ipairs(args) do
    args[key] = self:convert_to_grid(value)
  end
  return unpack(args)
end

function world_grid:grid_to_world(...)
  local args = { ... }
  for key, value in ipairs(args) do
    args[key] = self:convert_to_world(value)
  end
  return unpack(args)
end

return world_grid

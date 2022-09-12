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
  local was_table = true
  local args = ...

  if not (type(...) == "table") then
    args = { ... }
    was_table = false
  end

  for key, value in pairs(args) do
    args[key] = self:convert_to_grid(value)
  end

  if was_table then
    return args
  end
  return unpack(args)
end

function world_grid:grid_to_world(...)
  local was_table = true
  local args = ...

  if not (type(...) == "table") then
    args = { ... }
    was_table = false
  end

  for key, value in pairs(args) do
    args[key] = self:convert_to_world(value)
  end

  if was_table then
    return args
  end

  return unpack(args)
end

return world_grid

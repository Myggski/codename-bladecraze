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

function world_grid:grid_to_world(grid_x, grid_y)
  return self:convert_to_world(grid_x), self:convert_to_world(grid_y)
end

return world_grid

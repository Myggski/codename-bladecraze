local spatial_grid = {}

require("code.utilities.set")

function spatial_grid:create(bounds, dimensions)
    self.__index = self
    return setmetatable({
        bounds = bounds,
        dimensions = dimensions,
        cells = {}
    }, self)
end

local function hash_key(x, y)
    return (x .. "." .. y)
end

function spatial_grid:new_client(position, dimensions)
    local client = {
        position = position,
        dimensions = dimensions,
        indices = nil
    }
    self:insert(client)
    return client
end

function spatial_grid:get_cell_index(position)
    local x = math.clamp01((position.x - self.bounds.x_min) / (self.bounds.x_max - self.bounds.x_min))
    local y = math.clamp01((position.y - self.bounds.y_min) / (self.bounds.y_max - self.bounds.y_min))
    local xIndex = math.floor(x * self.dimensions.w)
    local yIndex = math.floor(y * self.dimensions.h)
    return xIndex, yIndex
end

function spatial_grid:draw()
    for y=1, grid.bounds.y_max, cell_height do
        for x=1, grid.bounds.x_max, cell_width do
          love.graphics.rectangle("line", x, y, cell_width, cell_height)
        end
    end
end

function spatial_grid:insert(client)
    local x1, y1 = client.position.x, client.position.y
    local w, h = client.dimensions.w, client.dimensions.h

    --local position1 = {x = x1 - w / 2, y = y1 - h / 2}
    local position1 = {x = x1, y = y1}
    local min_x_index, min_y_index = self:get_cell_index(position1)

    --local position2 = { x = x1 + w / 2, y = y1 + h / 2 }
    local position2 = { x = x1 + w, y = y1 + h }
    local max_x_index, max_y_index = self:get_cell_index(position2)

    client.indices = { min_x_index, min_y_index, max_x_index, max_y_index }
    
    for i = min_x_index, max_x_index do
        for j = min_y_index, max_y_index do
            local key = hash_key(i, j)
            
            if not set.contains(self.cells, key) then
                self.cells[key] = {} 
            end
            table.insert(self.cells[key], client)
        end
    end
end

function spatial_grid:find_near(position, bounds)
    local x1, y1 = position.x, position.y
    local w, h = bounds.w, bounds.h

    --local position1 = {x = x1 - w / 2, y = y1 - h / 2}
    local position1 = {x = x1, y = y1}
    local min_x_index, min_y_index = self:get_cell_index(position1)

    --local position2 = { x = x1 + w / 2, y = y1 + h / 2 }
    local position2 = { x = x1 + w, y = y1 + h}
    local max_x_index, max_y_index = self:get_cell_index(position2)

    local clients = {} --set
    
    for i = min_x_index, max_x_index do
        for j = min_y_index, max_y_index do
            local key = hash_key(i, j)
            if set.contains(self.cells, key) then
                for k, v in ipairs(self.cells[key]) do
                    set.add(clients, v)
                end
            end
        end
    end
    return clients
end

function spatial_grid:update(client)
    self:remove_client(client)
    self:insert(client)
end

function spatial_grid:remove_client(client)
    local min_x_index, min_y_index = client.indices[1], client.indices[2]
    local max_x_index, max_y_index = client.indices[3], client.indices[4]

    for i = min_x_index, max_x_index do
        for j = min_y_index, max_y_index do
            local key = hash_key(i, j)
            if (set.contains(self.cells, key)) then
                local index = table.index_of(self.cells[key], client)
                table.remove(self.cells[key], index)
            end
        end
    end
end

return spatial_grid

require("code.utilities.set")

local spatial_grid = {}

function spatial_grid:create(bounds)
    self.__index = self
    return setmetatable({
        bounds = bounds,
        cells = {}
    }, self)
end

local function hash_key(x, y)
    return (x .. "." .. y)
end

function spatial_grid:new_client(position, dimensions, guid)
    local client = {
        position = position,
        dimensions = dimensions,
        guid = guid,
        indices = nil
    }
    self:insert(client)
    return client
end

--[[
    get the player position between 0.0-1.0 of the bounds
    and return the matching cell indices
]]
function spatial_grid:get_cell_index(x, y)

    x = math.clamp01(x / self.bounds.x_max)
    y = math.clamp01(y / self.bounds.y_max)
    local xIndex = math.floor(x * GRID_COL_COUNT) + 1
    local yIndex = math.floor(y * GRID_ROW_COUNT) + 1
    return xIndex, yIndex
end

-- function spatial_grid:draw()
--     for y = 1, grid.bounds.y_max, cell_height do
--         for x = 1, grid.bounds.x_max, cell_width do
--             love.graphics.rectangle("line", x, y, cell_width, cell_height)
--         end
--     end
-- end

--[[
    insert the client into every cell that it occupies
]]
function spatial_grid:insert(client)

    local x, y = client.position.x, client.position.y
    local half_w, half_h = client.dimensions.w / 2, client.dimensions.h / 2

    local min_x_index, min_y_index = self:get_cell_index(x - half_w, y - half_h)
    local max_x_index, max_y_index = self:get_cell_index(x + half_w, y + half_h)

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

--[[
    check all the cells that the client occupies
    and return all the other clients that occupy the same 
]]
function spatial_grid:find_near(position, bounds, exclude_guids)
    local x, y = position.x, position.y
    local half_w, half_h = bounds.w / 2, bounds.h / 2

    local min_x_index, min_y_index = self:get_cell_index(x - half_w, y - half_h)
    local max_x_index, max_y_index = self:get_cell_index(x + half_w, y + half_h)

    local clients_set = {}

    for i = min_x_index, max_x_index do
        for j = min_y_index, max_y_index do
            local key = hash_key(i, j)
            if set.contains(self.cells, key) then
                for k, v in ipairs(self.cells[key]) do
                    if not set.contains(exclude_guids, v.guid) then
                        set.add(clients_set, v)
                    end
                end
            end
        end
    end
    return clients_set
end

function spatial_grid:update(client)
    self:remove_client(client)
    self:insert(client)
end

--[[
    remove the client from every cell that contains it
]]
function spatial_grid:remove_client(client)
    local min_x_index, min_y_index = client.indices[1], client.indices[2]
    local max_x_index, max_y_index = client.indices[3], client.indices[4]

    for i = min_x_index, max_x_index do
        for j = min_y_index, max_y_index do
            local key = hash_key(i, j)
            if set.contains(self.cells, key) then
                local index = table.index_of(self.cells[key], client)
                table.remove(self.cells[key], index)
            end
        end
    end
end

return spatial_grid

require "code.engine.set"
local components = require "code.engine.components"
local debug = require "code.engine.debug"
local world_grid = require "code.engine.world_grid"
local collision = require "code.engine.collision"

local spatial_grid = {}

function spatial_grid:create(bounds)
    self.__index = self
    return setmetatable({
        bounds = bounds,
        cells = {}
    }, self)
end

local function hash_key(x, y)
    return (x .. ";" .. y)
end

function spatial_grid:draw_debug()
    for y = self.bounds.y_min, self.bounds.y_max do
        for x = self.bounds.x_min, self.bounds.x_max do
            debug.gizmos.draw_rectangle(
                { x = world_grid:convert_to_world(x), y = world_grid:convert_to_world(y) },
                { x = world_grid:convert_to_world(1), y = world_grid:convert_to_world(1) }
            )
        end
    end
end

function spatial_grid:get_indices(position, size)
    local half_w, half_h = size.x * 0.5, size.y * 0.5

    local min_x_index, min_y_index = position.x - half_w, position.y - half_h
    local max_x_index, max_y_index = position.x + half_w, position.y + half_h

    return math.round(min_x_index), math.round(min_y_index), math.ceil(max_x_index), math.ceil(max_y_index)
end

--[[
    insert the client into every cell that it occupies
]]
function spatial_grid:insert(entity)
    local position = entity[components.position]
    local box_collider = entity[components.box_collider]
    local size = entity[components.size]

    if box_collider then
        position = collision.get_collider_position(position, box_collider)
        size = box_collider.size
    end

    local min_x_index, min_y_index = math.floor(position.x), math.floor(position.y)
    local max_x_index, max_y_index = math.floor(position.x + size.x - 0.001), math.floor(position.y + size.y - 0.001)

    for x = min_x_index, max_x_index do
        for y = min_y_index, max_y_index do
            local key = hash_key(x, y)

            if not set.contains(self.cells, key) then
                self.cells[key] = {}
            end

            table.insert(self.cells[key], entity)
        end
    end
end

--[[
    check all the cells that the client occupies
    and return all the other clients that occupy the same 
]]
function spatial_grid:find_near_entities(position, size, entities_to_exclude)
    local min_x_index, min_y_index, max_x_index, max_y_index = self:get_indices(position, size)
    local entity_set = {}
    min_x_index = min_x_index - 1
    min_y_index = min_y_index - 1

    for x = min_x_index, max_x_index do
        for y = min_y_index, max_y_index do
            local key = hash_key(x, y)

            if set.contains(self.cells, key) then
                for index = 1, #self.cells[key] do
                    if not set.contains(entities_to_exclude, self.cells[key][index]) then
                        set.add(entity_set, self.cells[key][index])
                    end
                end
            end
        end
    end

    return entity_set
end

function spatial_grid:find_at(position, size, entities_to_exclude)
    local min_x_index, min_y_index = math.floor(position.x), math.floor(position.y)
    local max_x_index, max_y_index = math.floor(position.x + size.x - 0.001), math.floor(position.y + size.y - 0.001)
    local entity_set = {}
    for x = min_x_index, max_x_index do
        for y = min_y_index, max_y_index do
            local key = hash_key(x, y)
            if set.contains(self.cells, key) then
                for index = 1, #self.cells[key] do
                    if not set.contains(entities_to_exclude, self.cells[key][index]) then
                        set.add(entity_set, self.cells[key][index])
                    end
                end
            end
        end
    end

    return entity_set
end

function spatial_grid:update(entity)
    self:remove(entity)
    self:insert(entity)
end

--[[
    Remove the client from every cell that contains it
    Remove-function needs to select a bigger grid than insert, because of position rounding
    E.g - The position is being rounded to int, and then the spatial grid updates.
    This can miss previous position that the entity was in before the rounding
]]
function spatial_grid:remove(entity)
    local position = entity[components.position]
    local box_collider = entity[components.box_collider]
    local size = entity[components.size]

    if box_collider then
        position = collision.get_collider_position(position, box_collider)
        size = box_collider.size
    end

    local min_x_index, min_y_index = math.floor(position.x - size.x), math.floor(position.y - size.y)
    local max_x_index, max_y_index = math.floor(position.x + size.x * 2), math.floor(position.y + size.y * 2)

    for x = min_x_index, max_x_index do
        for y = min_y_index, max_y_index do
            local key = hash_key(x, y)
            if set.contains(self.cells, key) then
                local index = table.index_of(self.cells[key], entity)
                if index > 0 then
                    table.remove(self.cells[key], index)
                    if #self.cells[key] == 0 then
                        self.cells[key] = nil
                    end
                end
            end
        end
    end
end

return setmetatable(spatial_grid, { __call = function(t, ...) return t:create(...) end })

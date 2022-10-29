local camera = require "code.engine.camera"
local vector2 = require "code.engine.vector2"

--[[
  9-Slice Scaling - Resizing Technique
  https://en.wikipedia.org/wiki/9-slice_scaling

  ---------------------------      ----------------------
  | 1 |        2        | 3 |      |   1  |   2  |   3  |
  ---------------------------      ----------------------
  |   |                 |   |      |   4  |   5  |   6  |
  | 4 |        5        | 6 |      ----------------------
  |   |                 |   |      |   7  |   8  |   9  |
  ---------------------------      ----------------------
  | 7 |        8        | 9 |
  ---------------------------
]]

local nine_slice_dots = { vector2(6, 6), vector2(10, 10) } -- nine_slice_dots is top-left and bottom-right of the center piece of a texture
local quad_data = { -- Hardcoding scalable quads for simplicity
  { scale_x = false, scale_y = false },
  { scale_x = true, scale_y = false },
  { scale_x = false, scale_y = false },
  { scale_x = false, scale_y = true },
  { scale_x = true, scale_y = true },
  { scale_x = false, scale_y = true },
  { scale_x = false, scale_y = false },
  { scale_x = true, scale_y = false },
  { scale_x = false, scale_y = false },
}

-- Creates a new quad for the setmetatable-function
local function new_quad(x1, y1, x2, y2, edge_x, edge_y)
  local x, y = x1, y1
  local width, height = x2 - x1, y2 - y1
  local quad = {
    x = x,
    y = y,
    width = width,
    height = height,
    edge_x = edge_x, -- If its at the far right of the 9-sliced grid (Boolean)
    edge_y = edge_y, -- If its at bottom of the 9-sliced grid (Boolean)
  }

  return { __index = quad }
end

-- Creates and setup all the data for the quads on a button
-- Sets the position and size in the texture, also sets if it's on the edge of the texture
local function setup_quad_data(image_width, image_height)
  -- Gets position of x and y position depending on the current and next column in the grid. Index 4 doesn't exsist so it ends where the image ends)
  local grid_position_x = { 0, nine_slice_dots[1].x, nine_slice_dots[2].x, image_width }
  local grid_position_y = { 0, nine_slice_dots[1].y, nine_slice_dots[2].y, image_height }

  for index = 0, table.get_size(quad_data) - 1 do
    local index_x, index_y = (index % 3) + 1, math.floor((index / 3) + 1)
    local start_x, start_y = grid_position_x[index_x], grid_position_y[index_y]
    local end_x, end_y = grid_position_x[index_x + 1], grid_position_y[index_y + 1]
    local edge_x, edge_y = end_x == image_width, end_y == image_height

    quad_data[index + 1] = setmetatable(quad_data[index + 1], new_quad(start_x, start_y, end_x, end_y, edge_x, edge_y))
  end
end

-- Creates a love2d quad
local function get_graphics_quad(index, sprite_offset_x, sprite_width, sprite_height)
  local quad_width, quad_height = quad_data[index].width, quad_data[index].height
  local quad_x, quad_y = quad_data[index].x + sprite_offset_x, quad_data[index].y

  return love.graphics.newQuad(quad_x, quad_y, quad_width, quad_height, sprite_width, sprite_height)
end

-- Returns all the quads for the ui, for all the animations
-- Assuming that the textures animation changes on the x-axis (width)
local function create_quads(sprite_batch, image_width, image_height)
  local sprite_batch_quads = {}
  local texture = sprite_batch:getTexture()
  local texture_width, texture_height = texture:getWidth(), texture:getHeight()

  setup_quad_data(image_width, image_height)
  for animation_index = 0, (texture_width / image_width) - 1 do
    local sprite_offset_x = image_width * animation_index

    for index = 1, table.get_size(quad_data) do
      table.insert(sprite_batch_quads, get_graphics_quad(index, sprite_offset_x, texture_width, texture_height))
    end
  end

  return sprite_batch_quads
end

-- Returns a quad with proper position and scale
local function setup_sprite_batch_quad(quads, index, x, y, width_to_add, height_to_add)
  local _, __, quad_width, quad_height = quads[index]:getViewport()
  local scale_x, scale_y = 1, 1
  local position_x, position_y = x + quad_data[index].x, y + quad_data[index].y

  -- Check if quad is a scalable quad
  if quad_data[index].scale_x then
    scale_x = math.max((width_to_add + quad_width) / quad_width, 1)
  end

  if quad_data[index].scale_y then
    scale_y = math.max((height_to_add + quad_height) / quad_height, 1)
  end

  -- Check if quad is the last quad on y- and/or x-axis and moves it
  if quad_data[index].edge_x then
    position_x = position_x + width_to_add
  end

  if quad_data[index].edge_y then
    position_y = position_y + height_to_add
  end

  return quads[index], position_x, position_y, 0, scale_x, scale_y
end

-- Sets the quads for the ui and sets them up with proper sizes and positions in the sprite batch
local function set_sprite_batch(position, size, image_width, image_height, quads, sprite_batch)
  local x, y = camera:screen_coordinates(position.x, position.y)
  local w, h = camera:screen_coordinates(size.x, size.y)
  local width_to_add, height_to_add = w - image_width, h - image_height

  for index = 1, #quads do
    sprite_batch:add(setup_sprite_batch_quad(quads, index, x, y, width_to_add,
      height_to_add))
  end
end

return {
  create_quads = create_quads,
  set_sprite_batch = set_sprite_batch,
}

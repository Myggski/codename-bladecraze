-- Break quads and sprite batch to seperate lua-file later, so more things can use it, not just buttons
-- Keeping nine_slice_dots for future, instead of hardcoding positions
-- local nine_slice_dots = {{ x = 6, y = 6 }, { x = 11, y = 6}, { x = 6, y = 11 }, { x = 11, y = 11 }}
local number_of_button_animations = table.get_size(BUTTON_ANIMATION_STATE_TYPES)

--[[
-  The position_index is the X or Y position in the 3x3 2d array of quads
-  Returns the position of the quad depending if the position_index is first, center or last in the 2d array
-  Hardcoding this for now
]]
local function get_quad_position(position_index)
  if (position_index == 1) then
    return 0
  elseif (position_index == 2) then
    return 6
  elseif (position_index == 3) then
    return 10
  end
end

--[[
-  Returns the size of the quad depending on the position in the 3x3 2d array of quads
-  Hardcoding this for now
]]
local function get_quad_size(x, y)
  if (x + y == 2 or x + y == 6 or x == 1 and y == 3 or x == 3 and y == 1) then -- Button corners
    return 6, 6
  elseif (x == 2 and y == 2) then -- Button center
    return 4, 4
  elseif (y == 2) then -- Button center edges
    return 6, 4
  end

  return 4, 6 -- The rest of the button
end

--[[
-  Creates and return quad depending on the position in the 3x3 2d array of quads
]]
local function create_quad(index, sprite_offset_x, sprite_width, sprite_height)
  local x = (index % 3) + 1
  local y = math.floor((index / 3) + 1)
  local quad_width, quad_height = get_quad_size(x, y)
  local quad_x, quad_y = get_quad_position(x) + sprite_offset_x, get_quad_position(y)

  return love.graphics.newQuad(quad_x, quad_y, quad_width, quad_height, sprite_width, sprite_height)
end

--[[
-  Returns active quads, depending on the animation state of the button
]]
local function get_active_quads(quads, animation_state)
  local current_quads = {}
  local number_of_quads = (table.get_size(quads) / number_of_button_animations)
  local animation_offset = animation_state - 1
  local animation_offset_index = 9 * animation_offset

  for index = 1, number_of_quads do
    table.insert(current_quads, quads[index + animation_offset_index])
  end

  return current_quads
end

--[[
-  Returns a quad with setup position and scale
]]
local function get_quad(active_quads, index, x, y, width_to_add, height_to_add)
  local quad_x = (index % 3) + 1
  local quad_y = math.floor((index / 3) + 1)
  local _, __, quad_width, quad_height = active_quads[index + 1]:getViewport()
  local is_scalable = (index % 2 == 1) or index == 4
  local is_at_edge = quad_x == 3 or quad_y == 3
  local scale_x, scale_y = 1, 1
  local position_x, position_y = x + get_quad_position(quad_x), y + get_quad_position(quad_y)

  -- Check if quad is a scalable quad
  if (is_scalable) then
    if (quad_y % 2 == 1 or index == 4) then
      scale_x = math.max((width_to_add + quad_width) / quad_width, 1)
    end

    if (not (quad_y % 2 == 1) or index == 4) then
      scale_y = math.max((height_to_add + quad_height) / quad_height, 1)
    end
  end

  -- Check if quad is the last quad on y- and/or x-axis and moves it
  if (is_at_edge) then
    if (quad_x == 3) then
      position_x = position_x + width_to_add
    end

    if (quad_y == 3) then
      position_y = position_y + height_to_add
    end
  end

  return active_quads[index + 1], position_x, position_y, 0, scale_x, scale_y
end

--[[
-  Returns all the quads for the button, for all the animations
]]
local function get_quads(sprite_width, sprite_height, image_width)
  local quads = {}

  for animation_index = 0, number_of_button_animations - 1 do
    local sprite_offset_x = image_width * animation_index;

    for index = 0, 8 do
      table.insert(quads, create_quad(index, sprite_offset_x, sprite_width, sprite_height)) -- top-left
    end
  end

  return quads
end

--[[
-  Creates and return all the quads for the button, for all the animations
-  Makes in simpler to just pass sprite_batch as property
]]
local function create_quads(sprite_batch)
  local texture = sprite_batch:getTexture()
  local image_width, image_height = texture:getWidth(), texture:getHeight()
  local single_image_width = image_width / number_of_button_animations

  return get_quads(image_width, image_height, single_image_width)
end

--[[
-  Returns sprite batch with quads for the current animation of the button
]]
local function get_sprite_batch(sprite_batch, rectangle, quads, animation_state)
  local active_quads = get_active_quads(quads, animation_state)
  local texture = sprite_batch:getTexture()
  local texture_width, texture_height = texture:getWidth(), texture:getHeight()
  local image_width, image_height = texture_width / number_of_button_animations, texture_height
  local width_to_add, height_to_add = rectangle.w - image_width, rectangle.h - image_height

  sprite_batch:clear()

  for i = 0, #active_quads - 1 do
    sprite_batch:add(get_quad(active_quads, i, rectangle.x, rectangle.y, width_to_add, height_to_add))
  end

  return sprite_batch
end

local function draw(button)
  button.sprite_batch = get_sprite_batch(button.sprite_batch, button.rectangle, button.quads, button.button_state)
  love.graphics.draw(button.sprite_batch)
end

return {
  create_quads = create_quads,
  draw = draw,
}

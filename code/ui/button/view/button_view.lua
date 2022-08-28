local asset_manager = require "code.engine.asset_manager"
local nine_slice_scaling = require "code.engine.nine_slice_scaling"
local camera = require "code.engine.camera"

--[[
  Return all the quads for the active animation
]]
local function _get_active_quads(button)
  local current_quads = {}
  local number_of_quads = (table.get_size(button.quads) / table.get_size(BUTTON_ANIMATION_STATE_TYPES))
  local animation_offset = button.animation_state - 1
  local animation_offset_index = number_of_quads * animation_offset

  for index = 1, number_of_quads do
    table.insert(current_quads, button.quads[index + animation_offset_index])
  end

  return current_quads
end

--[[
  Sets the correct quads for the sprite batch, depending on the button state
  Runs each draw-call
]]
local function _update_sprite_batch(button)
  local active_quads = _get_active_quads(button)
  local texture = button.sprite_batch:getTexture()

  nine_slice_scaling.set_sprite_batch(
    button,
    texture:getWidth() / table.get_size(BUTTON_ANIMATION_STATE_TYPES),
    texture:getHeight(),
    active_quads
  )
end

--[[
  Sets the button text in the center of the button and adds the text to the "text batch" that will be rendered later together
  When the button is being pressed down, the text should follow (animation-y-offset)
]]
local function _add_text(button, text_list)
  local button_center_x, button_center_y = button.rectangle:center()
  local text_width, text_height = asset_manager:get_text_size(button.font, button.text)
  local animation_y_offset = (button.animation_state - 1) * camera:get_scale()
  local text_x = button_center_x - text_width / 2
  local text_y = button_center_y - text_height / 2 + animation_y_offset

  return text_list:add(button.text, text_x, text_y)
end

--[[
  Sets the correct quads for the sprite batch and sets the text in the correct position
]]
local function draw(button, text_list)
  _update_sprite_batch(button)
  _add_text(button, text_list)
end

--[[
  Create all quads for all the animation states
]]
local function get_quads(sprite_batch)
  local texture = sprite_batch:getTexture()
  local image_width, image_height = texture:getWidth() / table.get_size(BUTTON_ANIMATION_STATE_TYPES),
      texture:getHeight()

  return nine_slice_scaling.create_quads(sprite_batch, image_width, image_height)
end

return {
  draw = draw,
  get_quads = get_quads,
}

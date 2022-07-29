local rectangle = require("code.core.rectangle")
local button = {}

function button:load_button(x, y)
  self.image = love.graphics.newImage(self.image_url)

  local image_width = self.image:getWidth();
  local image_height = self.image:getHeight();
  local quad_width = (image_width / table.get_size(BUTTON_ANIMATION_STATE_TYPES));
  local quad_height = image_height;

  local button_rectangle = rectangle:create(x, y, quad_width, quad_height)
  self.rectangle = button_rectangle

  local idle_quad = love.graphics.newQuad(0, 0, quad_width, quad_height, image_width, image_height) -- Idle
  local hover_quad = love.graphics.newQuad(quad_width, 0, quad_width, quad_height, image_width, image_height) -- Hover
  local click_quad = love.graphics.newQuad(quad_width * 2, 0, quad_width, quad_height, image_width, image_height) -- Click

  self.quads[BUTTON_ANIMATION_STATE_TYPES.DEFAULT] = idle_quad
  self.quads[BUTTON_ANIMATION_STATE_TYPES.HOVER] = hover_quad
  self.quads[BUTTON_ANIMATION_STATE_TYPES.CLICK] = click_quad
end

function button:get_quad()
  return self.quads[self.button_state]
end

function button:set_state(state)
  self.button_state_previous = self.button_state
  self.button_state = state
end

function button:clear_state()
  self.button_state = self.button_state_previous
  self.button_state_previous = BUTTON_ANIMATION_STATE_TYPES.DEFAULT
end

function button:add_listener(event_type, callback)
  self.callbacks[event_type] = self.callbacks[event_type] or {}
  table.insert(self.callbacks[event_type], callback)
end

function button:remove_listener(event_type, callback)
  local index = table.index_of(self.callbacks[event_type], callback)

  if (index) then
    table.remove(self.callbacks[event_type], index)
  end
end

function button:try_button_click(x, y, btn, is_touch, is_pressing)
  if btn == BUTTON_CLICK_TYPES.LEFT and self.rectangle:is_inside(x, y) and is_pressing then
    self:set_state(BUTTON_ANIMATION_STATE_TYPES.CLICK)

    for index, callback in pairs(self.callbacks[BUTTON_EVENT_TYPES.CLICK]) do
      callback()
     end
  elseif btn == BUTTON_CLICK_TYPES.LEFT and not is_pressing then
    self:clear_state()

    for index, callback in pairs(self.callbacks[BUTTON_EVENT_TYPES.RELEASE]) do
      callback()
     end
  end
end

function button:try_button_hover()
  local x, y = love.mouse.getPosition()
  if (self.rectangle:is_inside(x, y)) then
    if (not self.is_mouse_hovering) then
      self:set_state(BUTTON_ANIMATION_STATE_TYPES.HOVER)
      self.is_mouse_hovering = true 

      for _, callback in pairs(self.callbacks[BUTTON_EVENT_TYPES.ENTER]) do
        callback()
       end
    end
  elseif (self.is_mouse_hovering) then
    self:clear_state()
    self.is_mouse_hovering = false

    for _, callback in pairs(self.callbacks[BUTTON_EVENT_TYPES.LEAVE]) do
      callback()
     end
  end
end

return button

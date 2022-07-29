local game_event_manager = require("code.engine.game_event.game_event_manager")
local button_model = require("code.ui.button.model.button_model")
local button_view = require("code.ui.button.view.button_view")
local buttons = {
}

local function mousepressed(x, y, btn, is_touch)
  for index = 1, #buttons do
    local button = buttons[index]
    button:try_button_click(x, y, btn, is_touch, true)
  end
end

local function mousereleased(x, y, btn, is_touch, presses)
  for index = 1, #buttons do
    local button = buttons[index]
    button:try_button_click(x, y, btn, is_touch, false)
  end
end

local function update(dt)
  for index = 1, #buttons do
    local button = buttons[index]
    button:try_button_hover()
  end
end

local function draw()
  for index = 1, #buttons do
    local button = buttons[index]
    local quad = button_model.get_quad(button)
    button_view.draw(button.image, quad,  button.rectangle)
  end
end

local function remove_all()
  for index = 1, #buttons do
    local button = buttons[i]
    table.remove(buttons, table.index_of(button));
    button = nil
  end
end

function button_model:create(x, y, image_url)
  self.__index = self

  local obj = setmetatable({
    image_url = image_url,
    image = nil,
    rectangle = nil,
    is_mouse_hovering = false,
    button_state = BUTTON_ANIMATION_STATE_TYPES.DEFAULT,
    button_state_previous = BUTTON_ANIMATION_STATE_TYPES.DEFAULT,
    quads = {
      leave = nil,
      enter = nil,
      click = nil,
      release = nil,
    },
    callbacks = {
      click = {},
      release = {},
      enter = {},
      leave = {},
    }
  }, self)

  button_model.load_button(obj, x, y)
  table.insert(buttons, obj)

  return obj
end

function button_model:remove()
  table.remove(buttons, table.index_of(self));
  self = nil
end

game_event_manager:add_listener(GAME_EVENT_TYPES.MOUSE_PRESSED, mousepressed)
game_event_manager:add_listener(GAME_EVENT_TYPES.MOUSE_RELEASED, mousereleased)
game_event_manager:add_listener(GAME_EVENT_TYPES.UPDATE, update)
game_event_manager:add_listener(GAME_EVENT_TYPES.DRAW, draw)
game_event_manager:add_listener(GAME_EVENT_TYPES.QUIT, remove_all)

return button_model

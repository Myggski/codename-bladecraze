local game_event_manager = require("code.engine.game_event.game_event_manager")
local button_model = require("code.ui.button.model.button_model")
local button_view = require("code.ui.button.view.button_view")
local rectangle = require("code.engine.rectangle")
local font_silver = require("code.engine.font_silver")

local buttons = {}
local button_text_canvas = nil
local sprite_batch = nil
local quads = nil
local images = {}
local text_batch_list = {}

local function mousepressed(x, y, btn, is_touch)
  for index = 1, #buttons do
    local button = buttons[index]
    button:try_button_click(x, y, btn, is_touch, true)
  end
end

local function mousereleased(x, y, btn, is_touch)
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
  if #buttons == 0 then
    return
  end

  sprite_batch:clear()

  for _, text_batch in pairs(text_batch_list) do
    text_batch:clear()
  end

  for index = 1, #buttons do
    local button = buttons[index]
    button_view.draw(button)
  end

  love.graphics.draw(sprite_batch)

  for _, text_batch in pairs(text_batch_list) do
    love.graphics.draw(text_batch)
  end
end

local function remove_all()
  for index = #buttons, 1, -1 do
    local button = buttons[index]
    button.remove(button)
  end
end

local function add_events()
  game_event_manager:add_listener(GAME_EVENT_TYPES.MOUSE_PRESSED, mousepressed)
  game_event_manager:add_listener(GAME_EVENT_TYPES.MOUSE_RELEASED, mousereleased)
  game_event_manager:add_listener(GAME_EVENT_TYPES.UPDATE, update)
  game_event_manager:add_listener(GAME_EVENT_TYPES.DRAW, draw)
  game_event_manager:add_listener(GAME_EVENT_TYPES.QUIT, remove_all)
end

local function remove_events()
  game_event_manager:remove_listener(GAME_EVENT_TYPES.MOUSE_PRESSED, mousepressed)
  game_event_manager:remove_listener(GAME_EVENT_TYPES.MOUSE_RELEASED, mousereleased)
  game_event_manager:remove_listener(GAME_EVENT_TYPES.UPDATE, update)
  game_event_manager:remove_listener(GAME_EVENT_TYPES.DRAW, draw)
  game_event_manager:remove_listener(GAME_EVENT_TYPES.QUIT, remove_all)
end

local function setup_button(font)

  if (#buttons == 0) then
    if (images["assets/button.png"] == nil) then
      images["assets/button.png"] = love.graphics.newPixelImage("assets/button.png")
    end

    --if they use the same image, we can use the same sprite and sprite_batch
    if (sprite_batch == nil) then
      sprite_batch = love.graphics.newSpriteBatch(images["assets/button.png"])
    end

    if (quads == nil) then
      quads = button_view.create_quads(sprite_batch)
    end

    add_events()
  end

  if (text_batch_list[font:getHeight()] == nil) then
    text_batch_list[font:getHeight()] = love.graphics.newText(font)
  end
end

function button_model:remove()
  table.remove(buttons, table.index_of(self));
  self = nil

  if (#buttons == 0) then
    remove_events()
  end
end

function button_model:create(x, y, w, h, text, font)
  font = font or font_silver.normal
  self.__index = self

  setup_button(font)

  local obj = setmetatable({
    button_state = BUTTON_ANIMATION_STATE_TYPES.DEFAULT,
    button_state_previous = BUTTON_ANIMATION_STATE_TYPES.DEFAULT,
    sprite_batch = sprite_batch,
    rectangle = rectangle:create(x, y, w, h),
    is_mouse_hovering = false,
    quads = quads,
    text = text,
    font = font,
    texts = text_batch_list[font:getHeight()],
    callbacks = {
      click = {},
      release = {},
      enter = {},
      leave = {},
    }
  }, self)

  table.insert(buttons, obj)

  return obj
end

return button_model

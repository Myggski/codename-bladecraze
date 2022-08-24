local game_event_manager = require "code.engine.game_event.game_event_manager"
local button_model = require "code.ui.button.model.button_model"
local button_view = require "code.ui.button.view.button_view"
local rectangle = require "code.engine.rectangle"
local asset_manager = require "code.engine.asset_manager"

local Button = {
  buttons = {},
  sprite_batch = nil,
  quads = nil,
  text_batch_list = {},
}

function Button:_mousepressed(x, y, btn, _)
  for index = 1, #self.buttons do
    self.buttons[index]:try_click(x, y, btn, true)
  end
end

function Button:_mousereleased(x, y, btn, _)
  for index = 1, #self.buttons do
    self.buttons[index]:try_click(x, y, btn, false)
  end
end

function Button:_update(dt)
  for index = 1, #self.buttons do
    self.buttons[index]:try_hover()
  end
end

function Button:_draw()
  if #self.buttons == 0 then
    return
  end

  self.sprite_batch:clear()

  for _, text_batch in pairs(self.text_batch_list) do
    text_batch:clear()
  end

  for index = 1, #self.buttons do
    button_view.draw(self.buttons[index], self.text_batch_list[self.buttons[index].text_id])
  end

  love.graphics.draw(self.sprite_batch)

  for _, text_batch in pairs(self.text_batch_list) do
    love.graphics.draw(text_batch)
  end
end

function Button:_remove_all()
  for index = #self.buttons, 1, -1 do
    self:remove(self.buttons[index])
  end
end

function Button:remove(button)
  local index = table.index_of(self.buttons, button)

  if index then
    table.remove(self.buttons, index)
  end

  if (#self.buttons == 0) then
    self:_remove_events()
  end
end

function Button:_add_events()
  game_event_manager.add_listener(GAME_EVENT_TYPES.MOUSE_PRESSED, function(...) Button._mousepressed(self, ...) end)
  game_event_manager.add_listener(GAME_EVENT_TYPES.MOUSE_RELEASED, function(...) Button._mousereleased(self, ...) end)
  game_event_manager.add_listener(GAME_EVENT_TYPES.UPDATE, function(...) Button._update(self, ...) end)
  game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_HUD, function(...) Button._draw(self) end)
  game_event_manager.add_listener(GAME_EVENT_TYPES.QUIT, function(...) Button._remove_all(self) end)
end

function Button:_remove_events()
  game_event_manager.remove_listener(GAME_EVENT_TYPES.MOUSE_PRESSED, function(...) Button._mousepressed(self, ...) end)
  game_event_manager.remove_listener(GAME_EVENT_TYPES.MOUSE_RELEASED, function(...) Button._mousereleased(self, ...) end)
  game_event_manager.remove_listener(GAME_EVENT_TYPES.UPDATE, function(...) Button._update(self, ...) end)
  game_event_manager.remove_listener(GAME_EVENT_TYPES.DRAW_HUD, function(...) Button._draw(self) end)
  game_event_manager.remove_listener(GAME_EVENT_TYPES.QUIT, function(...) Button._remove_all(self) end)
end

function Button:_cache_button_data(font, text_id)
  if #self.buttons == 0 then
    self:_add_events()
  end

  if not (self.sprite_batch) then
    self.sprite_batch = love.graphics.newSpriteBatch(asset_manager:get_image("button.png"))
  end

  if not (self.quads) then
    self.quads = button_view.get_quads(self.sprite_batch)
  end

  if not (self.text_batch_list[text_id]) then
    self.text_batch_list[text_id] = love.graphics.newText(font)
  end
end

function Button:create(x, y, w, h, text, font)
  font = font or asset_manager:get_font("Silver.ttf", 16, "mono")

  local text_id = text .. font:getHeight()
  self:_cache_button_data(font, text_id)

  local button = button_model:create(
    rectangle:create(x, y, w, h),
    text,
    font,
    self.sprite_batch,
    self.quads
  )

  table.insert(self.buttons, button)

  return button
end

return Button

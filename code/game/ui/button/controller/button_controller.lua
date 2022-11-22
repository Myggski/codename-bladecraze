local game_event_manager = require "code.engine.game_event.game_event_manager"
local button_model = require "code.game.ui.button.model.button_model"
local button_view = require "code.game.ui.button.view.button_view"
local camera = require "code.engine.camera"
local asset_manager = require "code.engine.asset_manager"
local vector2 = require "code.engine.vector2"

local button = {
  _buttons = {},
  _text_batch_list = {},
  _quads = {},
  _sprite_batch = nil,
}

function button:_mousepressed(x, y, button_position, _)
  for index = 1, #self._buttons do
    if self._buttons[index].enabled then
      self._buttons[index]:try_click(x, y, button_position, true)
    end
  end
end

function button:_mousereleased(x, y, button_position, _)
  for index = 1, #self._buttons do
    if self._buttons[index].enabled then
      self._buttons[index]:try_click(x, y, button_position, false)
    end
  end
end

function button:_update()
  for index = 1, #self._buttons do
    if self._buttons[index].enabled then
      self._buttons[index]:try_hover()
    end
  end
end

function button:_draw()
  if #self._buttons == 0 then
    return
  end

  self._sprite_batch:clear()

  for _, text_batch in pairs(self._text_batch_list) do
    text_batch:clear()
  end

  for index = 1, #self._buttons do
    button_view.draw(self._buttons[index], self._text_batch_list[self._buttons[index].text_id])
  end

  love.graphics.draw(self._sprite_batch, 0, 0, 0, camera:get_scale())

  for _, text_batch in pairs(self._text_batch_list) do
    love.graphics.draw(text_batch)
  end
end

function button:_remove_all()
  for index = #self._buttons, 1, -1 do
    self:remove(self._buttons[index])
  end
end

function button:remove(button)
  local index = table.index_of(self._buttons, button)

  if index > -1 then
    table.remove(self._buttons, index)
  end

  if #self._buttons == 0 then
    self:_remove_events()
  end
end

function button:_add_events()
  game_event_manager.add_listener(GAME_EVENT_TYPES.MOUSE_PRESSED, function(...) button._mousepressed(self, ...) end)
  game_event_manager.add_listener(GAME_EVENT_TYPES.MOUSE_RELEASED, function(...) button._mousereleased(self, ...) end)
  game_event_manager.add_listener(GAME_EVENT_TYPES.UPDATE, function() button._update(self) end)
  game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_HUD, function(...) button._draw(self) end)
  game_event_manager.add_listener(GAME_EVENT_TYPES.QUIT, function(...) button._remove_all(self) end)
end

function button:_remove_events()
  game_event_manager.remove_listener(GAME_EVENT_TYPES.MOUSE_PRESSED, function(...) button._mousepressed(self, ...) end)
  game_event_manager.remove_listener(GAME_EVENT_TYPES.MOUSE_RELEASED, function(...) button._mousereleased(self, ...) end)
  game_event_manager.remove_listener(GAME_EVENT_TYPES.UPDATE, function() button._update(self) end)
  game_event_manager.remove_listener(GAME_EVENT_TYPES.DRAW_HUD, function(...) button._draw(self) end)
  game_event_manager.remove_listener(GAME_EVENT_TYPES.QUIT, function(...) button._remove_all(self) end)
end

function button:_cache_button_data(font, text)
  if #self._buttons == 0 then
    self:_add_events()
  end

  if not (self._sprite_batch) then
    self._sprite_batch = love.graphics.newSpriteBatch(asset_manager:get_image("button.png"))
  end

  if #self._quads == 0 then
    self._quads = button_view.get_quads(self._sprite_batch)
  end

  local text_id = text .. font:getHeight()
  if not (self._text_batch_list[text_id]) then
    self._text_batch_list[text_id] = love.graphics.newText(font)
  end
end

function button:create(x, y, w, h, text, font)
  font = font or asset_manager:get_font("Silver.ttf")
  text = text or ""

  self:_cache_button_data(font, text)

  -- TODO: Fix this so it can be smaller than image_size * scale
  -- Sets the min width and height to 16px (same size as the image)
  w = math.max(w, 16 * camera:get_scale())
  h = math.max(h, 16 * camera:get_scale())

  local new_button = button_model(
    vector2(x, y),
    vector2(w, h),
    text,
    font,
    self._sprite_batch,
    self._quads
  )

  table.insert(self._buttons, new_button)

  return new_button
end

return setmetatable(button, { __call = function(t, ...) return t:create(...) end })

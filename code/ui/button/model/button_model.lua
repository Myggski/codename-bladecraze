local camera = require "code.engine.camera"
local player_input = require "code.player.player_input"

local button_model = {}

function button_model:_set_state(state)
  self.animation_state_previous = self.animation_state
  self.animation_state = state
end

function button_model:_clear_state()
  self.animation_state = self.animation_state_previous
  self.animation_state_previous = BUTTON_ANIMATION_STATE_TYPES.DEFAULT
end

function button_model:add_listener(event_type, callback)
  self.callbacks[event_type] = self.callbacks[event_type] or {}
  table.insert(self.callbacks[event_type], callback)
end

function button_model:remove_listener(event_type, callback)
  local index = table.index_of(self.callbacks[event_type], callback)

  if index then
    table.remove(self.callbacks[event_type], index)
  end
end

function button_model:try_click(x, y, btn, is_pressing)
  if btn == BUTTON_CLICK_TYPES.LEFT and is_pressing and self.rectangle:is_inside(x, y) then
    self:_set_state(BUTTON_ANIMATION_STATE_TYPES.CLICK)

    for _, callback in pairs(self.callbacks[BUTTON_EVENT_TYPES.CLICK]) do
      callback()
    end
  elseif btn == BUTTON_CLICK_TYPES.LEFT and not is_pressing then
    self:_clear_state()

    for _, callback in pairs(self.callbacks[BUTTON_EVENT_TYPES.RELEASE]) do
      callback()
    end
  end
end

function button_model:try_hover()
  if self.rectangle:is_inside(love.mouse.getPosition()) then
    if not self.is_mouse_hovering then
      self:_set_state(BUTTON_ANIMATION_STATE_TYPES.HOVER)
      self.is_mouse_hovering = true

      for _, callback in pairs(self.callbacks[BUTTON_EVENT_TYPES.ENTER]) do
        callback()
      end
    end
  elseif self.is_mouse_hovering then
    self:_clear_state()
    self.is_mouse_hovering = false

    for _, callback in pairs(self.callbacks[BUTTON_EVENT_TYPES.LEAVE]) do
      callback()
    end
  end
end

function button_model:create(rectangle, text, font, sprite_batch, quads)
  return setmetatable({
    animation_state = BUTTON_ANIMATION_STATE_TYPES.DEFAULT,
    animation_state_previous = BUTTON_ANIMATION_STATE_TYPES.DEFAULT,
    font = font,
    is_mouse_hovering = false,
    rectangle = rectangle,
    sprite_batch = sprite_batch,
    text = text or "",
    text_id = text .. font:getHeight(),
    quads = quads,
    callbacks = {
      click = {},
      release = {},
      enter = {},
      leave = {},
    }
  }, { __index = self })
end

return setmetatable(button_model, { __index = button_model, __call = function(table, ...) return table:create(...) end })

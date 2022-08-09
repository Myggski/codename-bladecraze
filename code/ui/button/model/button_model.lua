local camera = require("code.engine.camera")
local button_model = {}

function button_model:set_state(state)
  self.button_state_previous = self.button_state
  self.button_state = state
end

function button_model:clear_state()
  self.button_state = self.button_state_previous
  self.button_state_previous = BUTTON_ANIMATION_STATE_TYPES.DEFAULT
end

function button_model:add_listener(event_type, callback)
  self.callbacks[event_type] = self.callbacks[event_type] or {}
  table.insert(self.callbacks[event_type], callback)
end

function button_model:remove_listener(event_type, callback)
  local index = table.index_of(self.callbacks[event_type], callback)

  if (index) then
    table.remove(self.callbacks[event_type], index)
  end
end

function button_model:try_button_click(screen_x, screen_y, btn, is_touch, is_pressing)
  local world_x, world_y = camera:screen_to_world(screen_x, screen_y)
  if btn == is_pressing and BUTTON_CLICK_TYPES.LEFT and self.rectangle:is_inside(world_x, world_y) then
    self:set_state(BUTTON_ANIMATION_STATE_TYPES.CLICK)

    for _, callback in pairs(self.callbacks[BUTTON_EVENT_TYPES.CLICK]) do
      callback()
    end
  elseif btn == BUTTON_CLICK_TYPES.LEFT and not is_pressing then
    self:clear_state()

    for _, callback in pairs(self.callbacks[BUTTON_EVENT_TYPES.RELEASE]) do
      callback()
    end
  end
end

function button_model:try_button_hover()
  local screen_x, screen_y = love.mouse.getPosition()
  local world_x, world_y = camera:screen_to_world(screen_x, screen_y)

  if (self.rectangle:is_inside(world_x, world_y)) then
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

return button_model

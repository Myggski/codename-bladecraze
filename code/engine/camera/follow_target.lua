local camera = require "code.engine.camera"
local world_grid = require "code.engine.world_grid"
local game_event_manager = require "code.engine.game_event.game_event_manager"

local ZOOM_ANIMATION_STEP = 1
local ZOOM_ANIMATION_SPEED = 0.0625
local ZOOM_ANIMATION_STATE = {
  NONE = 0,
  IN = 1,
  OUT = 2,
}

local follow_target = {
  _targets = {},
}

-- TODO: Change to better name
-- Checks if it's outside zoom area, if it's outside the camera should zoom out
function follow_target._is_outside(rectangle, margin_percentage)
  margin_percentage = margin_percentage or 0

  local x, y = camera:get_position()
  local _, half_height = world_grid:world_to_grid(camera:get_screen_game_half_size())
  half_height = half_height - half_height * margin_percentage

  local is_outside_x = rectangle.x < x - half_height or rectangle.x + rectangle.w > x + half_height
  local is_outside_y = rectangle.y < y - half_height or rectangle.y + rectangle.h > y + half_height

  return is_outside_x or is_outside_y
end

-- Checks if the camera should zoom in or zoom out
function follow_target:_get_zoom_animation_state()
  local furthest_target = self:_get_furthest_target()
  local is_inside_outer = self._is_outside(furthest_target.box, 0.05)
  local is_inside_inner = self._is_outside(furthest_target.box, 0.5)
  local animation_state = ZOOM_ANIMATION_STATE.NONE

  if camera:can_zoom_out() and is_inside_outer then
    animation_state = ZOOM_ANIMATION_STATE.OUT
  elseif camera:can_zoom_in() and not is_inside_inner then
    animation_state = ZOOM_ANIMATION_STATE.IN
  end

  return animation_state
end

function follow_target:_set_camera_zoom()
  local animation_state = self:_get_zoom_animation_state()

  -- If there's no coroutine set and animation_state is not NONE, create a coroutine for the animation
  if self.zoom_animation_coroutine == nil and not (animation_state == ZOOM_ANIMATION_STATE.NONE) then
    self.zoom_animation_coroutine = coroutine.create(function()
      self:_animate_zoom(animation_state)
    end)
  end

  -- If a coroutine is set and is not done yet, continue with the animation
  if not (self.zoom_animation_coroutine == nil) and coroutine.status(self.zoom_animation_coroutine) == "suspended" then
    coroutine.resume(self.zoom_animation_coroutine)
  end
end

-- Sets the zoom within the zoom bound
function follow_target._zoom_game(zoom_value)
  camera:set_zoom(camera:get_zoom() + zoom_value)
  camera:set_canvas_game(camera:get_screen_game_size())
end

-- Gets the following targets thats furthest on x and y axis
function follow_target:_get_furthest_target()
  local furthest_target = nil
  local x, y = camera:get_position()

  for index = 1, table.get_size(self._targets) do
    local target = self._targets[index]
    local distance = math.dist(x, y, target.box:center_x(), target.box:center_y())

    if furthest_target == nil or
        distance > math.dist(x, y, furthest_target.box:center_x(), furthest_target.box:center_y()) then
      furthest_target = target
    end
  end

  return furthest_target
end

-- Sets the position of where the camera should look
function follow_target:_set_camera_position()
  local number_of_targets = table.get_size(self._targets)
  local position_x, position_y = 0, 0

  for index = 1, number_of_targets do
    local target = self._targets[index]
    local center_x, center_y = target.box:center()

    position_x = position_x + center_x
    position_y = position_y + center_y
  end

  position_x = position_x / number_of_targets
  position_y = position_y / number_of_targets

  camera:look_at(position_x, position_y)
end

-- A animation coroutine for the camera zoom
function follow_target:_animate_zoom(animation_state)
  local zoom_step = ZOOM_ANIMATION_STEP
  local zoom_speed = ZOOM_ANIMATION_SPEED / camera:get_zoom_aspect_ratio() -- Keeps the speed and steps linear

  while zoom_step > 0 do
    zoom_step = zoom_step - zoom_speed
    self._zoom_game(animation_state == ZOOM_ANIMATION_STATE.OUT and -zoom_speed or zoom_speed)
    coroutine.yield()
  end

  self.zoom_animation_coroutine = nil
end

-- Adds target to follow
function follow_target:add_target(target)
  table.insert(self._targets, target)
  self:_set_camera_position()
end

-- Removes target to follow
function follow_target:remove_target(target)
  local index = table.index_of(self._targets, target)

  if not (index == -1) then
    table.remove(self._targets, index)
    self:_set_camera_position()
  end
end

function follow_target:load()
  game_event_manager.add_listener(GAME_EVENT_TYPES.UPDATE, function(...) self:_late_update() end)
end

function follow_target:_late_update()
  if #self._targets > 0 then
    self:_set_camera_zoom()
    self:_set_camera_position()
  end
end

return follow_target

local game_event_manager = require "code.engine.game_event.game_event_manager"
local world_grid = require "code.engine.world_grid"
local camera = require "code.engine.camera"
local vector2 = require "code.engine.vector2"

local player_input = {}
local mouse_pressed = false
local analog_stick_deadzone = 0.2
local available_joysticks = {} -- The joysticks that's connected but not active
local active_controllers = {} -- Can be both joysticks and keyboard

local function mousepressed(x, y, btn, is_touch)
  mouse_pressed = true
end

local function mousereleased(x, y, btn, is_touch)
  mouse_pressed = false
end

local function get_digital_axis(player_controller)
  local pressed_keys = { up = false, down = false, left = false, right = false }
  local controller = player_controller.controller
  local x, y = 0, 0

  if player_input.is_keyboard(player_controller.type) then
    pressed_keys.left = controller.isDown(KEYBOARD.LEFT) or controller.isDown(KEYBOARD.A)
    pressed_keys.right = controller.isDown(KEYBOARD.RIGHT) or controller.isDown(KEYBOARD.D)
    pressed_keys.up = controller.isDown(KEYBOARD.UP) or controller.isDown(KEYBOARD.W)
    pressed_keys.down = controller.isDown(KEYBOARD.DOWN) or controller.isDown(KEYBOARD.S)
  elseif player_input.is_gamepad(player_controller.type) then
    pressed_keys.left = controller:isGamepadDown(GAMEPAD.BUTTONS.DP_LEFT)
    pressed_keys.right = controller:isGamepadDown(GAMEPAD.BUTTONS.DP_RIGHT)
    pressed_keys.up = controller:isGamepadDown(GAMEPAD.BUTTONS.DP_UP)
    pressed_keys.down = controller:isGamepadDown(GAMEPAD.BUTTONS.DP_DOWN)
  end

  if pressed_keys.right then
    x = x + 1
  end
  if pressed_keys.left then
    x = x - 1
  end
  if pressed_keys.up then
    y = y - 1
  end
  if pressed_keys.down then
    y = y + 1
  end
  return x, y
end

local function get_action(player_controller)
  local controller = player_controller.controller
  local action = PLAYER.ACTIONS.NONE

  if player_input.is_keyboard(player_controller.type) then
    action = mouse_pressed and PLAYER.ACTIONS.BASIC or PLAYER.ACTIONS.NONE
    action = controller.isDown(KEYBOARD.Q) and PLAYER.ACTIONS.SPECIAL or action
    action = controller.isDown(KEYBOARD.R) and PLAYER.ACTIONS.ULTIMATE or action
  elseif player_input.is_gamepad(player_controller.type) then
    action = controller:isGamepadDown(GAMEPAD.BUTTONS.A) and PLAYER.ACTIONS.BASIC or PLAYER.ACTIONS.NONE
    action = controller:isGamepadDown(GAMEPAD.BUTTONS.B) and PLAYER.ACTIONS.ULTIMATE or action
    action = controller:isGamepadDown(GAMEPAD.BUTTONS.X) and PLAYER.ACTIONS.SPECIAL or action
  end

  return action
end

local function get_move_direction(player_controller)
  local move_dir = vector2.zero()

  move_dir.x, move_dir.y = get_digital_axis(player_controller)

  if player_input.is_gamepad(player_controller.type) and player_controller.controller:isGamepad() then
    local lx, ly = player_controller.controller:getGamepadAxis(GAMEPAD.AXES.LEFT_X),
        player_controller.controller:getGamepadAxis(GAMEPAD.AXES.LEFT_Y)
    if math.abs(lx) > analog_stick_deadzone then
      move_dir.x = lx
    end
    if math.abs(ly) > analog_stick_deadzone then
      move_dir.y = ly
    end
  end

  return move_dir
end

local function joystick_added(joystick)
  table.insert(available_joysticks, joystick)
end

local function joystick_removed(joystick)
  local index = table.index_of(available_joysticks, joystick)

  if index > 0 then
    table.remove(available_joysticks, index)
  end
end

function player_input.active_controller(controller_type, joystick)
  local player_id = (player_input.get_non_active_ids())[1]
  table.insert(
    active_controllers,
    player_id,
    {
      player_id = player_id,
      type = controller_type,
      controller = joystick and joystick or love.keyboard,
    }
  )

  return player_id
end

function player_input.deactivate_controller(controller_type, joystick)
  local active_controller, is_removing_keyboard = nil, nil

  for active_index = #active_controllers, 1, -1 do
    active_controller = active_controllers[active_index]
    is_removing_keyboard = player_input.is_keyboard(controller_type) and active_controller.type == controller_type

    if is_removing_keyboard or active_controller.controller == joystick then
      if active_controller.connected_player then
        active_controller.connected_player:destroy()
      end

      table.remove(active_controllers, active_index)
      return active_index
    end
  end

  return -1
end

function player_input.toggle_player_activation(controller_type, joystick)
  if not player_input.is_pressing_start(controller_type, joystick) then
    return
  end

  if player_input.is_controller_active(controller_type, joystick) then
    player_input.deactivate_controller(controller_type, joystick)
  else
    player_input.active_controller(controller_type, joystick)
  end
end

function player_input.is_pressing_start(controller_type, joystick)
  if player_input.is_gamepad(controller_type) then
    return joystick and joystick:isGamepadDown(GAMEPAD.BUTTONS.START)
  end

  return love.keyboard.isDown(KEYBOARD.SPACE, KEYBOARD.ENTER)
end

function player_input.is_controller_active(controller_type, joystick)
  if player_input.is_gamepad(controller_type) then
    for index = 1, #active_controllers do
      if active_controllers[index].controller == joystick then
        return true
      end
    end

    return false
  end

  return player_input.is_keyboard_active()
end

function player_input.get_input(player_id)
  local player_controller = active_controllers[player_id]
  local input = {
    move_dir = vector2.zero(),
    action = PLAYER.ACTIONS.NONE,
  }

  if player_controller then
    input.move_dir = math.normalize2(get_move_direction(player_controller))
    input.action = get_action(player_controller)
  end

  return input
end

function player_input.get_available_joysticks() return available_joysticks end

function player_input.get_active_controllers() return active_controllers end

function player_input.get_active_joysticks()
  local gamepad_controllers = {}

  for index = 1, #active_controllers do
    if player_input.is_gamepad(active_controllers[index].type) then
      table.insert(gamepad_controllers, active_controllers[index])
    end
  end

  return gamepad_controllers
end

function player_input.get_non_active_ids()
  local possible_ids, remove_index = { 1, 2, 3, 4 }, -1

  for index = 1, #active_controllers do
    remove_index = table.index_of(possible_ids, active_controllers[index].player_id)

    table.remove(possible_ids, remove_index)
  end

  return possible_ids
end

function player_input.get_active_player_ids()
  local player_ids = {}

  for index = 1, #active_controllers do
    table.insert(player_ids, active_controllers[index].player_id)
  end

  return player_ids
end

function player_input.is_keyboard_active()
  local is_keyboard_active = false

  for index = 1, #active_controllers do
    if player_input.is_keyboard(active_controllers[index].type) then
      is_keyboard_active = true
      break
    end
  end

  return is_keyboard_active
end

function player_input.is_keyboard(controller_type)
  return controller_type == CONTROLLER_TYPES.KEYBOARD
end

function player_input.is_gamepad(controller_type)
  return controller_type == CONTROLLER_TYPES.GAMEPAD
end

-- Returns the mouse position on the screen
function player_input.mouse_position_screen() return camera:screen_coordinates(love.mouse.getPosition()) end

-- Returns the mouse position in the world
function player_input.mouse_position_world()
  local x, y = player_input:mouse_position_screen()
  local half_w, half_h = camera:get_screen_game_half_size()
  local camera_x, camera_y = world_grid:grid_to_world(camera:get_position())

  return (x * camera:get_zoom_aspect_ratio()) + camera_x - half_w,
      (y * camera:get_zoom_aspect_ratio()) + camera_y - half_h
end

function player_input.mouse_position_grid() return world_grid:world_to_grid(player_input:mouse_position_world()) end

game_event_manager.add_listener(GAME_EVENT_TYPES.JOYSTICK_ADDED, joystick_added)
game_event_manager.add_listener(GAME_EVENT_TYPES.JOYSTICK_REMOVED, joystick_removed)
game_event_manager.add_listener(GAME_EVENT_TYPES.MOUSE_PRESSED, mousepressed)
game_event_manager.add_listener(GAME_EVENT_TYPES.MOUSE_RELEASED, mousereleased)

return player_input

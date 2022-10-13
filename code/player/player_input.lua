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
  local controller = player_controller.controller
  local x, y = 0, 0
  local pressed_keys = {
    up = false,
    down = false,
    left = false,
    right = false,
  }

  if player_controller.type == CONTROLLER_TYPES.KEYBOARD then
    pressed_keys.left = controller.isDown("left") or controller.isDown("a")
    pressed_keys.right = controller.isDown("right") or controller.isDown("d")
    pressed_keys.up = controller.isDown("up") or controller.isDown("w")
    pressed_keys.down = controller.isDown("down") or controller.isDown("s")
  elseif player_controller.type == CONTROLLER_TYPES.GAMEPAD then
    pressed_keys.left = controller:isGamepadDown("dpleft")
    pressed_keys.right = controller:isGamepadDown("dpright")
    pressed_keys.up = controller:isGamepadDown("dpup")
    pressed_keys.down = controller:isGamepadDown("dpdown")
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

  if player_controller.type == CONTROLLER_TYPES.KEYBOARD then
    action = mouse_pressed and PLAYER.ACTIONS.BASIC or PLAYER.ACTIONS.NONE
    action = controller.isDown("q") and PLAYER.ACTIONS.SPECIAL or action
    action = controller.isDown("r") and PLAYER.ACTIONS.ULTIMATE or action
  elseif player_controller.type == CONTROLLER_TYPES.GAMEPAD then
    action = controller:isGamepadDown("a") and PLAYER.ACTIONS.BASIC or PLAYER.ACTIONS.NONE
    action = controller:isGamepadDown("b") and PLAYER.ACTIONS.ULTIMATE or action
    action = controller:isGamepadDown("x") and PLAYER.ACTIONS.SPECIAL or action
  end

  return action
end

local function get_move_direction(player_controller)
  local move_dir = vector2.zero()

  if player_controller.type == CONTROLLER_TYPES.GAMEPAD then
    local lx, ly = player_controller.controller:getGamepadAxis("leftx"),
        player_controller.controller:getGamepadAxis("lefty")
    if math.abs(lx) > analog_stick_deadzone then
      move_dir.x = lx
    end
    if math.abs(ly) > analog_stick_deadzone then
      move_dir.y = ly
    end
  else
    move_dir.x, move_dir.y = get_digital_axis(player_controller)
  end

  return move_dir
end

local function joystick_added(joystick)
  if joystick:isGamepad() then
    table.insert(available_joysticks, joystick)
  end
end

local function joystick_removed(joystick)
  local index = table.index_of(available_joysticks, joystick)

  for active_index = 1, #active_controllers do
    if joystick == active_controllers[active_index].controller then
      table.remove(active_controllers, joystick)
    end
  end

  if index > 0 then
    table.remove(available_joysticks, index)
  end
end

local keyboard_activity_check = function(key, controller_activition_callback)
  local has_keyboard = false

  for index = 1, #active_controllers do
    if active_controllers[index].type == CONTROLLER_TYPES.KEYBOARD then
      has_keyboard = true
      break
    end
  end

  if has_keyboard then
    return
  end

  if key == "return" or key == "space" then
    local controller = {
      type = CONTROLLER_TYPES.KEYBOARD,
      controller = love.keyboard,
    }

    table.insert(active_controllers, controller)
    controller_activition_callback()
  end
end

local gamepad_activity_check = function(joystick, controller_activition_callback)
  local has_gamepad = false

  for index = 1, #active_controllers do
    if active_controllers[index].type == CONTROLLER_TYPES.GAMEPAD then
      if joystick == active_controllers[index].controller then
        has_gamepad = true
        break
      end
    end
  end

  if not has_gamepad and joystick:isGamepadDown("start") then
    local controller = {
      type = CONTROLLER_TYPES.GAMEPAD,
      controller = joystick,
    }

    table.insert(active_controllers, controller)
    controller_activition_callback()
  end
end

local player_key_pressed_event = nil
local player_joystick_pressed_event = nil

function player_input.add_on_player_activated(controller_activition_callback)
  player_input.remove_on_player_activated()

  player_key_pressed_event = function(key) keyboard_activity_check(key, controller_activition_callback) end
  player_joystick_pressed_event = function(joystick) gamepad_activity_check(joystick, controller_activition_callback) end

  game_event_manager.add_listener(GAME_EVENT_TYPES.KEY_PRESSED, player_key_pressed_event)
  game_event_manager.add_listener(GAME_EVENT_TYPES.JOYSTICK_PRESSED, player_joystick_pressed_event)
end

function player_input.remove_on_player_activated()
  if player_key_pressed_event then
    game_event_manager.remove_listener(GAME_EVENT_TYPES.KEY_PRESSED, player_key_pressed_event)
    player_key_pressed_event = nil
  end

  if player_joystick_pressed_event then
    game_event_manager.remove_listener(GAME_EVENT_TYPES.JOYSTICK_PRESSED, player_joystick_pressed_event)
    player_joystick_pressed_event = nil
  end
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

local game_event_manager = require "code.engine.game_event.game_event_manager"
local world_grid = require "code.engine.world_grid"
local camera = require "code.engine.camera"

local player_input = {}
local mouse_pressed = false
local analog_stick_deadzone = 0.2

local function mousepressed(x, y, btn, is_touch)
  mouse_pressed = true
end

local function mousereleased(x, y, btn, is_touch)
  mouse_pressed = false
end

local function get_digital_axis(joystick, keyboard)
  local x, y = 0, 0
  local pressed_keys = { up = false, down = false, left = false, right = false }
  --Get keyboard or controller-dpad input
  if keyboard then
    pressed_keys.left = keyboard.isDown("left") or keyboard.isDown("a")
    pressed_keys.right = keyboard.isDown("right") or keyboard.isDown("d")
    pressed_keys.up = keyboard.isDown("up") or keyboard.isDown("w")
    pressed_keys.down = keyboard.isDown("down") or keyboard.isDown("s")
  elseif joystick then
    pressed_keys.left = joystick:isGamepadDown("dpleft")
    pressed_keys.right = joystick:isGamepadDown("dpright")
    pressed_keys.up = joystick:isGamepadDown("dpup")
    pressed_keys.down = joystick:isGamepadDown("dpdown")
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

local function get_action(joystick, keyboard)
  local action = PLAYER.ACTIONS.NONE
  if keyboard then
    action = mouse_pressed and PLAYER.ACTIONS.BASIC or PLAYER.ACTIONS.NONE
    action = keyboard.isDown("q") and PLAYER.ACTIONS.SPECIAL or action
    action = keyboard.isDown("r") and PLAYER.ACTIONS.ULTIMATE or action
  elseif joystick then
    action = joystick:isGamepadDown("a") and PLAYER.ACTIONS.BASIC or PLAYER.ACTIONS.NONE
    action = joystick:isGamepadDown("b") and PLAYER.ACTIONS.ULTIMATE or action
    action = joystick:isGamepadDown("x") and PLAYER.ACTIONS.SPECIAL or action
  end
  return action
end

local function get_move_direction(joystick, keyboard)
  local move_dir = { x = 0, y = 0 }
  if joystick then
    local lx, ly = joystick:getGamepadAxis("leftx"), joystick:getGamepadAxis("lefty")
    if math.abs(lx) > analog_stick_deadzone then
      move_dir.x = lx
    end
    if math.abs(ly) > analog_stick_deadzone then
      move_dir.y = ly
    end
  else
    move_dir.x, move_dir.y = get_digital_axis(nil, keyboard)
  end
  return move_dir
end

local function get_aim_direction(joystick, mouse, player_position)
  local aim_dir = { x = 0, y = 0 }
  if joystick then
    local rx, ry = joystick:getGamepadAxis("rightx"), joystick:getGamepadAxis("righty")
    if math.abs(rx) > analog_stick_deadzone then
      aim_dir.x = rx
    end
    if math.abs(ry) > analog_stick_deadzone then
      aim_dir.y = ry
    end
  else
    local mouse_x, mouse_y = player_input.mouse_position_grid()
    aim_dir.x = mouse_x - (player_position.x)
    aim_dir.y = mouse_y - (player_position.y)
  end
  return aim_dir
end

local joysticks = {}
local function joystick_added(joystick)
  if joystick:isGamepad() then
    table.insert(joysticks, joystick)
  end
end

local function joystick_removed(joystick)
  local index = table.index_of(joysticks, joystick)
  if index then
    table.remove(joysticks, index)
  end
end

function player_input.get_input(index, position)
  local input = { move_dir = { x = 0, y = 0 }, aim_dir = { x = 0, y = 0 }, action = PLAYER.ACTIONS.NONE }
  if #joysticks > 1 and index > 1 then
    if index - 1 <= #joysticks then
      input.move_dir = get_move_direction(joysticks[index - 1])
      input.aim_dir = get_aim_direction(joysticks[index - 1])
      input.action = get_action(joysticks[index - 1])
    end
  else
    if index == 1 then
      input.move_dir = get_move_direction(nil, love.keyboard)
      input.aim_dir = get_aim_direction(nil, love.mouse, position)
      input.action = get_action(nil, love.keyboard)
    elseif #joysticks == 1 and index == 2 then
      input.move_dir = get_move_direction(joysticks[1])
      input.aim_dir = get_aim_direction(joysticks[1])
      input.action = get_action(joysticks[1])
    end
  end

  input.aim_dir = math.normalize2(input.aim_dir)
  input.move_dir = math.normalize2(input.move_dir)

  return input
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

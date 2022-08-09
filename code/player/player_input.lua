
local game_event_manager = require("code.engine.game_event.game_event_manager")

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
  if keyboard == true then
    local keyboard = love.keyboard
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

local joysticks = {}
local function joystick_added(joystick)
  if (joystick:isGamepad()) then
    table.insert(joysticks, joystick)
  end
end

local function joystick_removed(joystick)
  local index = table.index_of(joysticks, joystick)
  if (index) then
    table.remove(joysticks, index)
  end
end

function player_input.get_input(index, position)
  local x, y = position.x, position.y
  local input = { move_dir = {x = 0, y = 0}, aim_dir = {x = 0, y = 0} }
  if #joysticks > 1 and index > 1 then
    if index-1 <= #joysticks then
      input.move_dir.x, input.move_dir.y = get_digital_axis(joysticks[index-1], nil)
    end
  else
    if index == 1 then
      input.move_dir.x, input.move_dir.y = get_digital_axis(nil, true)
      local mouse_x, mouse_y = love.mouse.getPosition()

      --Make this use the screen to world 
      input.aim_dir.x = mouse_x - (x * 5)
      input.aim_dir.y = mouse_y - (y * 5)
      input.shoot = mouse_pressed 
    elseif #joysticks == 1 and index == 2 then
      local lx, ly = joysticks[1]:getGamepadAxis("leftx"), joysticks[1]:getGamepadAxis("lefty")
      local rx, ry = joysticks[1]:getGamepadAxis("rightx"), joysticks[1]:getGamepadAxis("righty")
      if (math.abs(lx) > analog_stick_deadzone) then
        input.move_dir.x = lx
      end
      if (math.abs(ly) > analog_stick_deadzone) then
        input.move_dir.y = ly
      end
      if (math.abs(rx) > analog_stick_deadzone) then
        input.aim_dir.x = rx
      end
      if (math.abs(ry) > analog_stick_deadzone) then
        input.aim_dir.y = ry
      end
      input.shoot = joysticks[1]:isGamepadDown("a")
    end
  end

  input.aim_dir = math.normalize2(input.aim_dir)
  input.move_dir = math.normalize2(input.move_dir)
  
  return input
end

game_event_manager:add_listener(GAME_EVENT_TYPES.JOYSTICK_ADDED, joystick_added)
game_event_manager:add_listener(GAME_EVENT_TYPES.JOYSTICK_REMOVED, joystick_removed)
game_event_manager:add_listener(GAME_EVENT_TYPES.MOUSE_PRESSED, mousepressed)
game_event_manager:add_listener(GAME_EVENT_TYPES.MOUSE_RELEASED, mousereleased)

return player_input

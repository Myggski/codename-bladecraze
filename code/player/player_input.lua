
local game_event_manager = require("code.engine.game_event.game_event_manager")

local player_input = {}
local function get_digital_axis(joystick)
  local value = { x = 0, y = 0 }
  local pressed_keys = { up = false, down = false, left = false, right = false }
  --Get keyboard or controller-dpad input
  if joystick == nil then
    local keyboard = love.keyboard
    pressed_keys.left = keyboard.isDown("left") or keyboard.isDown("a")
    pressed_keys.right = keyboard.isDown("right") or keyboard.isDown("d")
    pressed_keys.up = keyboard.isDown("up") or keyboard.isDown("w")
    pressed_keys.down = keyboard.isDown("down") or keyboard.isDown("s")
  else
    pressed_keys.left = joystick:isGamepadDown("dpleft")
    pressed_keys.right = joystick:isGamepadDown("dpright")
    pressed_keys.up = joystick:isGamepadDown("dpup")
    pressed_keys.down = joystick:isGamepadDown("dpdown")
  end

  if pressed_keys.right then
    value.x = value.x + 1
  end
  if pressed_keys.left then
    value.x = value.x - 1
  end
  if pressed_keys.up then
    value.y = value.y - 1
  end
  if pressed_keys.down then
    value.y = value.y + 1
  end
  return value
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

function player_input:get_input(index)
  local input = { x = 0, y = 0 }

  if #joysticks > 1 and index <= #joysticks then
    input = get_digital_axis(joysticks[index])
  else
    if index == 1 then
      input = get_digital_axis()
    elseif #joysticks == 1 and index == 2 then
      input = get_digital_axis(joysticks[1])
    end
  end

  input = math.normalize2(input)
  return input
end

game_event_manager:add_listener(GAME_EVENT_TYPES.JOYSTICK_ADDED, joystick_added)
game_event_manager:add_listener(GAME_EVENT_TYPES.JOYSTICK_REMOVED, joystick_removed)

return player_input

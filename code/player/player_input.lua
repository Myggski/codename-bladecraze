player_input = {}

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

function player_input:get_input(index)
  local input = { x = 0, y = 0 }
  local joysticks = love.joystick.getJoysticks()
  if #joysticks > 1 then
    input = get_digital_axis(joysticks[index])
  else
    if index == 1 then
      input = get_digital_axis()
    elseif #joysticks == 1 and index == 2 then
      input = get_digital_axis(joysticks[1])
    end
  end
  input.x, input.y = math.normalize(input.x, input.y)
  return input
end

return player_input

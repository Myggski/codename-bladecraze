local player_input = {}

local function get_digital_axis(joystick)
    local value = {x=0,y=0}
    local pressedKeys = {up = false, down = false, left = false, right = false}

    --Get keyboard or controller-dpad input
    if joystick == nil then
        pressedKeys.left = love.keyboard.isDown("left") or love.keyboard.isDown("a")
        pressedKeys.right = love.keyboard.isDown("right") or love.keyboard.isDown("d")
        pressedKeys.up = love.keyboard.isDown("up") or love.keyboard.isDown("w")
        pressedKeys.down = love.keyboard.isDown("down") or love.keyboard.isDown("s")
    else
        pressedKeys.left = joystick:isGamepadDown("dpleft")
        pressedKeys.right = joystick:isGamepadDown("dpright")
        pressedKeys.up = joystick:isGamepadDown("dpup")
        pressedKeys.down = joystick:isGamepadDown("dpdown")
    end

    if pressedKeys.right then
        value.x = value.x + 1
    end
    if pressedKeys.left then
        value.x = value.x - 1
    end
    if pressedKeys.up then
        value.y = value.y - 1
    end
    if pressedKeys.down then
        value.y = value.y + 1
    end
    return value
end

function player_input:get_input(index)
    local input = {x = 0, y = 0}
    local joysticks = love.joystick.getJoysticks()
    if #joysticks > 1 then
        input = get_digital_axis(joysticks[index])
    else
        if index == 1 then
            input = get_digital_axis()
        elseif #joysticks == 1 then
            input = get_digital_axis(joysticks[1])
        end
    end
    input.x, input.y = math.normalize(input.x, input.y)
    return input
end

return player_input
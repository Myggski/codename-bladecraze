require "code.engine.constants.global_types"
require "code.engine.constants.game_data"
require "code.engine.extensions.love_extension"
require "code.engine.extensions.table_extension"
require "code.engine.extensions.math_extension"

local camera = require "code.engine.camera"
local game_event_manager = require "code.engine.game_event.game_event_manager"
local lobby = require "code.game.levels.lobby"

function love.load()
  camera:load()
  lobby.load()
  game_event_manager.invoke(GAME_EVENT_TYPES.LOAD)
end

function love.update(dt)
  game_event_manager.invoke(GAME_EVENT_TYPES.UPDATE, dt)
  game_event_manager.invoke(GAME_EVENT_TYPES.LATE_UPDATE, dt)
end

function love.draw()
  camera:start_draw_world()
  game_event_manager.invoke(GAME_EVENT_TYPES.DRAW_WORLD)
  camera:stop_draw_world()

  camera:start_draw_hud()
  game_event_manager.invoke(GAME_EVENT_TYPES.DRAW_HUD)
  camera:stop_draw_hud()
end

function love.mousepressed(x, y, btn, is_touch)
  game_event_manager.invoke(GAME_EVENT_TYPES.MOUSE_PRESSED, x, y, btn, is_touch)
end

function love.mousereleased(x, y, btn, is_touch, pressed)
  game_event_manager.invoke(GAME_EVENT_TYPES.MOUSE_RELEASED, x, y, btn, is_touch, pressed)
end

function love.joystickadded(joystick)
  game_event_manager.invoke(GAME_EVENT_TYPES.JOYSTICK_ADDED, joystick)
end

function love.joystickremoved(joystick)
  game_event_manager.invoke(GAME_EVENT_TYPES.JOYSTICK_REMOVED, joystick)
end

function love.joystickpressed(joystick, button)
  game_event_manager.invoke(GAME_EVENT_TYPES.JOYSTICK_PRESSED, joystick, button)
end

function love.joystickreleased(joystick, button)
  game_event_manager.invoke(GAME_EVENT_TYPES.JOYSTICK_RELEASED, joystick, button)
end

function love.keypressed(key, scancode, is_repeat)
  game_event_manager.invoke(GAME_EVENT_TYPES.KEY_PRESSED, key, scancode, is_repeat)

  if key == "escape" then
    love.event.quit()
  end
end

function love.keyreleased(key, scancode)
  game_event_manager.invoke(GAME_EVENT_TYPES.KEY_RELEASED, key, scancode)
end

--Can be stopped by returning true instead
function love.quit()
  local ready_to_quit = false
  game_event_manager.invoke(GAME_EVENT_TYPES.QUIT, ready_to_quit)
  return ready_to_quit
end

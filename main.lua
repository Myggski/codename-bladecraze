require "code.engine.constants.global_types"
require "code.engine.constants.game_data"
require "code.engine.extensions.love_extension"
require "code.engine.extensions.table_extension"
require "code.engine.extensions.math_extension"

local camera = require "code.engine.camera"
local game_event_manager = require "code.engine.game_event.game_event_manager"
local level_manager = require "code.engine.level_manager"
local lobby = require "code.game.levels.lobby"
local game_level = require "code.game.levels.game_level"

local fixed_dt = 1 / 60
local show_fps = false

io.stdout:setvbuf("no")

function love.load()
  level_manager:initialize({
    lobby,
    game_level,
  })

  camera:load()
  game_event_manager.invoke(GAME_EVENT_TYPES.LOAD)
end

function love.update(dt)
  dt = dt < fixed_dt and dt or fixed_dt
  game_event_manager.invoke(GAME_EVENT_TYPES.UPDATE, dt)
  game_event_manager.invoke(GAME_EVENT_TYPES.LATE_UPDATE, dt)
end

function love.draw()
  camera:start_draw_world()
  game_event_manager.invoke(GAME_EVENT_TYPES.DRAW_WORLD)
  game_event_manager.invoke(GAME_EVENT_TYPES.DRAW_WORLD_DEBUG)
  camera:stop_draw_world()

  camera:start_draw_hud()
  game_event_manager.invoke(GAME_EVENT_TYPES.DRAW_HUD)
  game_event_manager.invoke(GAME_EVENT_TYPES.DRAW_HUD_DEBUG)
  camera:stop_draw_hud()

  if show_fps then
    love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 10, 10)
  end
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

  if key == "f1" then
    show_fps = not show_fps
  end

  if key == "f11" then
    fullscreen = not fullscreen
    love.window.setFullscreen(fullscreen, "exclusive")
  end

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

require("code.engine.global_types")
require("code.engine.game_data")
require("code.utilities.love_extension")
require("code.utilities.table_extension")
require("code.utilities.extended_math")

local camera = require("code.engine.camera")


--[[
  Due to the level listening to game_events,
  only a require is needed to load it.

  We will have to change that later when we make
  a level select of some kind
]]
local level1 = require("code.level1")

local game_event_manager = require("code.engine.game_event.game_event_manager")

local draw_canvas = {}

function love.load()
  draw_canvas = love.graphics.newCanvas(camera.visual_resolution_x, camera.visual_resolution_y)
  draw_canvas:setFilter("nearest", "nearest")

  game_event_manager:invoke(GAME_EVENT_TYPES.LOAD)
end

function love.update(dt)
  game_event_manager:invoke(GAME_EVENT_TYPES.UPDATE, dt)
end

function love.draw()
  love.graphics.setCanvas(draw_canvas)
  love.graphics.clear(0, 0, 0, 0) -- Resets canvas

  game_event_manager:invoke(GAME_EVENT_TYPES.DRAW, draw_canvas)

  for i = 1, #players do
    players[i]:draw()
  end

  love.graphics.setCanvas()
  love.graphics.draw(draw_canvas, 0, 0, 0, camera:get_scale());
end

function love.mousepressed(x, y, btn, is_touch)
  game_event_manager:invoke(GAME_EVENT_TYPES.MOUSE_PRESSED, x, y, btn, is_touch)
end

function love.mousereleased(x, y, btn, is_touch, pressed)
  game_event_manager:invoke(GAME_EVENT_TYPES.MOUSE_RELEASED, x, y, btn, is_touch, pressed)
end

function love.joystickadded(joystick)
  game_event_manager:invoke(GAME_EVENT_TYPES.JOYSTICK_ADDED, joystick)
end

function love.joystickremoved(joystick)
  game_event_manager:invoke(GAME_EVENT_TYPES.JOYSTICK_REMOVED, joystick)
end

--Can be stopped by returning true instead
function love.quit()
  local ready_to_quit = false
  game_event_manager:invoke(GAME_EVENT_TYPES.QUIT, ready_to_quit)
  return ready_to_quit
end

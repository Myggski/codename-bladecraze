require "code.engine.global_types"
require "code.engine.game_data"
require "code.utilities.love_extension"
require "code.utilities.table_extension"
require "code.utilities.math_extension"
local entity_manager = require "code.engine.data.entity.entity_manager"
local component = require "code.engine.data.component.component"
--[[
  Due to the level listening to game_events,
  only a require is needed to load it.

  We will have to change that later when we make
  a level select of some kind
]]
require "code.level1"

local camera = require "code.engine.camera"
local game_event_manager = require "code.engine.game_event.game_event_manager"

function love.load()
  camera:load()
  game_event_manager.invoke(GAME_EVENT_TYPES.LOAD)
  local e1 = entity_manager:create();
  local e2 = entity_manager:create();
  local position_component = component()
  local pc = component({ x = 4, y = 4 })

  e1.add_component(e1, position_component, { x = 0, y = 0 })
  e1.add_component(e2, position_component, { x = 4, y = 4 })

  print(e1[position_component], e1[position_component].x, e1[position_component].y)
  print(e2[position_component], e2[position_component].x, e2[position_component].y)
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
  game_event_manager:invoke(GAME_EVENT_TYPES.JOYSTICK_REMOVED, joystick)
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

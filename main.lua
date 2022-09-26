require "code.engine.global_types"
require "code.engine.game_data"
require "code.utilities.love_extension"
require "code.utilities.table_extension"
require "code.utilities.math_extension"
local ecs = require "code.engine.ecs"

--[[
  Due to the level listening to game_events,
  only a require is needed to load it.

  We will have to change that later when we make
  a level select of some kind
]]
require "code.level1"

local camera = require "code.engine.camera"
local game_event_manager = require "code.engine.game_event.game_event_manager"
local level_one

function love.load()
  camera:load()
  game_event_manager.invoke(GAME_EVENT_TYPES.LOAD)

  level_one = ecs.world()

  local entityOne = level_one:entity()
  local entityTwo = level_one:entity()
  local entityThree = level_one:entity()
  local position_component = ecs.component({ x = 32, y = 8 })
  local size_component = ecs.component({ w = 1, h = 2 })
  local acceleration_component = ecs.component(100)

  entityOne[position_component] = position_component()
  entityTwo[position_component] = position_component({ x = 0, y = 0 })
  entityThree[position_component] = position_component({ x = 0, y = 0 })

  entityTwo[acceleration_component] = acceleration_component()

  entityThree[size_component] = size_component({ w = 2, h = 3 })

  local query = ecs.entity_query.all(position_component).none(size_component)

  local some_system = ecs.system(query, function(self, dt)
    for _, entity in pairs(self:entities()) do
      print(entity[position_component].x, entity[position_component].y)
    end
  end)

  level_one:add_system(some_system)
end

function love.update(dt)
  game_event_manager.invoke(GAME_EVENT_TYPES.UPDATE, dt)
  game_event_manager.invoke(GAME_EVENT_TYPES.LATE_UPDATE, dt)
  level_one:update(dt)
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

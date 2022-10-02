require "code.engine.global_types"
require "code.engine.game_data"
require "code.utilities.love_extension"
require "code.utilities.table_extension"
require "code.utilities.math_extension"
local rectangle = require "code.engine.rectangle"
local world_grid = require "code.engine.world_grid"
local ecs = require "code.engine.ecs"
local debug = require "code.utilities.debug"

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

  math.randomseed(os.clock() * 100000000000)
  level_one = ecs.world()

  local position_component = ecs.component({ x = 32, y = 8 })
  local size_component = ecs.component({ w = 1, h = 2 })
  local acceleration_component = ecs.component({ x = 0, y = 0 })

  local draw_datas = {}

  for i = 1, 4000 do
    local x, y, a_x, a_y = math.random(-640 / 5, 640 / 5), math.random(-360 / 5, 360 / 5), math.random(-10, 10),
        math.random(-10, 10)
    local entity = level_one:entity(position_component({ x = x, y = y }), acceleration_component({ x = a_x, y = a_y }))

    local color = { math.random(0, 1), math.random(0, 1), math.random(0, 1) }
    local draw_data = debug.gizmos.create_draw_data(debug.gizmos.DRAW_SPACE.WORLD, debug.gizmos.DRAW_MODE.FILL, color, 1)
    draw_datas[entity] = draw_data
  end

  local query = ecs.entity_query.all(position_component).none(size_component)

  local some_system = ecs.system(query, function(self, dt)
    for _, entity in self:list() do
      local pos = entity[position_component]
      local acc = entity[acceleration_component]

      entity[position_component] = { x = pos.x + acc.x * dt, y = pos.y + acc.y * dt }

      debug.gizmos.draw_rectangle(draw_datas[entity], entity[position_component], { x = 1, y = 1 }, { x = 0, y = 0 }, nil
        , dt)
    end
  end)

  level_one:add_system(some_system)
end

function love.update(dt)
  game_event_manager.invoke(GAME_EVENT_TYPES.UPDATE, dt)
  game_event_manager.invoke(GAME_EVENT_TYPES.LATE_UPDATE, dt)
  level_one:update(dt)

  print(love.timer.getFPS())
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

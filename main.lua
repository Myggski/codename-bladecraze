require("code.utilitizes.table_extension")
require("code.engine.global_types")
local game_event_manager = require("code.engine.game_event.game_event_manager")

function love.load()
  game_event_manager:invoke(GAME_EVENT_TYPES.LOAD)
end

function love.update(dt)
  game_event_manager:invoke(GAME_EVENT_TYPES.UPDATE, dt)
end

function love.draw()
  game_event_manager:invoke(GAME_EVENT_TYPES.DRAW)
end

function love.mousepressed(x, y, btn, is_touch)
  game_event_manager:invoke(GAME_EVENT_TYPES.MOUSE_PRESSED, x, y, btn, is_touch)
end

function love.mousereleased(x, y, btn, is_touch, pressed)
  game_event_manager:invoke(GAME_EVENT_TYPES.MOUSE_RELEASED, x, y, btn, is_touch, pressed)
end

-- Can be stopped by returning false instead
function love.quit()
  local ready_to_quit = true
  game_event_manager:invoke(GAME_EVENT_TYPES.QUIT, ready_to_quit)

  return ready_to_quit
end
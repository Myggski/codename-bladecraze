require("code.engine.global_types")
require("code.utilities.table_extension")
require("code.utilities.extended_math")
require("code.utilities.set")

local game_event_manager = require("code.engine.game_event.game_event_manager")
local player_character = require("code.player.player")
local animations = require("code.engine.animations")
local Rectangle = require("code.engine.rectangle")

function love.load()
  game_event_manager:invoke(GAME_EVENT_TYPES.LOAD)

  sprite_sheet_image = love.graphics.newImage("assets/0x72_DungeonTilesetII_v1.4.png")
  
  --Create 4 players
  players = {}
  for i=1,4 do
    local position = {i * 100, 200}
    local bounds = {16, 28}
    
	  players[i] = player_character:create
    {
      image = sprite_sheet_image,
      position = position,
      bounds = bounds,
      index = i,
    }
  end
end

function love.update(dt)
  game_event_manager:invoke(GAME_EVENT_TYPES.UPDATE, dt)
  local x, y = love.mouse.getPosition()
  for i=1, #players do
	  local player, rect = players[i], players[i].box
	  player:update(dt)
  end
end

function love.draw()
  game_event_manager:invoke(GAME_EVENT_TYPES.DRAW)
  for i=1, #players do
	  players[i]:draw()
  end
end

function love.mousepressed(x, y, btn, is_touch)
  game_event_manager:invoke(GAME_EVENT_TYPES.MOUSE_PRESSED, x, y, btn, is_touch)
end

function love.mousereleased(x, y, btn, is_touch, pressed)
  game_event_manager:invoke(GAME_EVENT_TYPES.MOUSE_RELEASED, x, y, btn, is_touch, pressed)
end

-- Can be stopped by returning true instead
function love.quit()
  local ready_to_quit = false
  game_event_manager:invoke(GAME_EVENT_TYPES.QUIT, ready_to_quit)

  return ready_to_quit
end

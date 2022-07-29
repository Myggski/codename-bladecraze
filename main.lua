require("code.utilitizes.table_extension")
require("code.engine.global_types")
local game_event_manager = require("code.engine.game_event.game_event_manager")
local Player = require("code.player.player")
local Animation = require("code.engine.animations")
local Rectangle = require("code.engine.rectangle")
require("code.utilities.extended_math")
require("code.utilities.set")
require("code.engine.spatial_grid")

function love.load()
  game_event_manager:invoke(GAME_EVENT_TYPES.LOAD)
  --Create player animation
  anim_coords = {{x=128,y=4}, {x=128,y=68}, {x=128,y=196}, {x=128,y=164}}
  local animationData = {
      image = love.graphics.newImage("assets/0x72_DungeonTilesetII_v1.4.png"),
      width = 16, height = 28,
      offsetX = 128, offsetY = 4,
      frameCount = 4, duration = 4
  }
  --Create 2 players
  players = {}
  for i=1,4 do
      animationData.offsetX = anim_coords[i].x
      animationData.offsetY = anim_coords[i].y
      players[i] = Player:create(i*100, 200, i, Animation.newAnimation(animationData), Rectangle:create(i*100, i*100, 16, 28))
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

-- Can be stopped by returning false instead
function love.quit()
  local ready_to_quit = true
  game_event_manager:invoke(GAME_EVENT_TYPES.QUIT, ready_to_quit)

  return ready_to_quit
end
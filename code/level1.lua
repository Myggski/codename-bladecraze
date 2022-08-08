require("code.utilities.set")
local spatial_grid = require("code.engine.spatial_grid")
local game_event_manager = require("code.engine.game_event.game_event_manager")
local camera = require("code.engine.camera")
local player_character = require("code.player.player")
local button = require("code.ui.button.button")
local level1 = {}

local grid = {}
local players = {}
local projectile_manager = require("code.projectile")

local active_entities = {}

local sprite_sheet_image = nil
function create_grid()
  local scale = camera:get_scale()
  local bounds = { x_min = 0, y_min = 0, x_max = 1280/scale.x, y_max = 720/scale.y }
  local dimensions = { w = 16, h = 9}
  grid = spatial_grid:create(bounds, dimensions)
end

function create_players()
  local characters = { "elf", "wizard", "knight", "lizard" }
  players = {}
  for i = 1, 2 do
    local player_position = {i*40, 32 }
    local player_bounds = { 16, 16 }
    
    players[i] = player_character:create
    {
      image = sprite_sheet_image,
      position = player_position,
      bounds = player_bounds,
      index = i,
      character = characters[i],
      grid = grid
    }
    set.add(active_entities, players[i])
  end
end

local function entity_activated(entity)
  set.add(active_entities, entity)
end

local function entity_deactivated(entity)
  set.delete(active_entities, index)
end

local function load()
  sprite_sheet_image = love.graphics.newPixelImage("assets/0x72_DungeonTilesetII_v1.4.png")
  button:create(0, 0, "assets/button.png")
  create_grid()
  create_players()
  local projectile_pool_size = 20
  for key, value in pairs(PROJECTILE_TYPES) do
    projectile_manager.projectile:create_pool(sprite_sheet_image, value, projectile_pool_size)
  end
end

local function update(dt)
  for entity, active in pairs(active_entities) do
    if active then
      entity:update(dt)
    end
  end
end
local function draw_grid()
  local cell_height = grid.bounds.y_max/grid.dimensions.h
  local cell_width = grid.bounds.x_max/grid.dimensions.w

  for y=0, grid.bounds.y_max, cell_height do
    for x=0, grid.bounds.x_max, cell_width do
      love.graphics.rectangle("line", x, y, cell_width, cell_height)
    end
  end
  love.graphics.setColor(1,0,1,1)
  love.graphics.rectangle("line", 0, 0, grid.bounds.x_max, grid.bounds.y_max)
end
local function draw()
  --draw_grid()
  for entity, active in pairs(active_entities) do
    if (active) then
      entity:draw()
    end
  end
end

game_event_manager:add_listener(GAME_EVENT_TYPES.UPDATE, update)
game_event_manager:add_listener(GAME_EVENT_TYPES.DRAW, draw)
game_event_manager:add_listener(GAME_EVENT_TYPES.LOAD, load)
game_event_manager:add_listener(ENTITY_EVENT_TYPES.ACTIVATED, entity_activated)
game_event_manager:add_listener(ENTITY_EVENT_TYPES.DEACTIVATED, entity_deactivated)

return level1
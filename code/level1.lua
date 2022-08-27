require "code.utilities.set"

local spatial_grid = require "code.engine.spatial_grid"
local game_event_manager = require "code.engine.game_event.game_event_manager"
local camera_follow = require "code.engine.camera_follow"
local player_character = require "code.player.player"
local button = require "code.ui.button.button"
local projectile_pool = require "code.projectiles.projectile_pool"

local asset_manager = require("code.engine.asset_manager")
local level1 = {}
local grid = {}
local players = {}
local active_entities = {}
local sprite_sheet_image = nil

local function create_grid()
  local bounds = { x_min = 0, y_min = 0, x_max = GAME.GAME_WIDTH, y_max = GAME.GAME_HEIGHT }
  grid = spatial_grid:create(bounds)
end

local function create_players()
  local classes = { "elf", "wizard", "knight", "lizard" }
  players = {}
  for i = 1, 2 do
    local player_position = { i * 2, 2 }
    local player_bounds = { 1, 1.75 }

    players[i] = player_character:create
    {
      image = sprite_sheet_image,
      position = player_position,
      bounds = player_bounds,
      index = i,
      class = classes[i],
      grid = grid
    }

    set.add(active_entities, players[i])
    camera_follow:add_target(players[i])
  end
end

local function entity_activated(entity)
  set.add(active_entities, entity)
end

local function entity_deactivated(entity)
  set.delete(active_entities, entity)
end

local function load()
  camera_follow:load()

  sprite_sheet_image = asset_manager:get_image("0x72_DungeonTilesetII_v1.4.png")
  button(16, 16, 196, 108, "Start")
  button(16, 136, 196, 108, "Quit")

  create_grid()
  create_players()

  local projectile_pool_size = 20
  for _, value in pairs(GAME.PROJECTILE_TYPES) do
    if not (value == GAME.PROJECTILE_TYPES.NONE) then
      projectile_pool:create(sprite_sheet_image, value, projectile_pool_size, grid)
    end
  end
end

local function update(dt)
  for entity, active in pairs(active_entities) do
    if active then
      entity:update(dt)
    end
  end
end

local function draw()
  grid:draw_debug()
  for entity, active in pairs(active_entities) do
    if active then
      entity:draw()
    end
  end
end

game_event_manager.add_listener(GAME_EVENT_TYPES.UPDATE, update)
game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_WORLD, draw)
game_event_manager.add_listener(GAME_EVENT_TYPES.LOAD, load)
game_event_manager.add_listener(ENTITY_EVENT_TYPES.ACTIVATED, entity_activated)
game_event_manager.add_listener(ENTITY_EVENT_TYPES.DEACTIVATED, entity_deactivated)

return level1

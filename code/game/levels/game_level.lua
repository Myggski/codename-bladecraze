local background_image = require "code.game.entities.background_image"
local walls = require "code.game.entities.walls"
local game_event_manager = require "code.engine.game_event.game_event_manager"
local player_input = require "code.game.player_input"
local world = require "code.engine.ecs.world"
local vector2 = require "code.engine.vector2"
local level_generator = require "code.engine.level_generator"
local player = require "code.game.entities.player"
local camera = require "code.engine.camera"

-- systems
local input_system = require "code.game.systems.input_system"
local input_velocity_system = require "code.game.systems.input_velocity_system"
local movement_system = require "code.game.systems.movement_system"
local animate_system = require "code.game.systems.animate_system"
local animation_set_state_system = require "code.game.systems.animation_set_state_system"
local collision_system = require "code.game.systems.collision_system"
local entity_draw = require "code.game.entity_draw"

local level
local draw

local function on_update(dt)
  level:update(dt)
end

local function on_draw()
  draw:update(level)
end

local function destroy()
  player_input.remove_on_player_activated()
  level:destroy()
end

local function print_level_to_console(level_data)
  local word = "|"
  local border = string.rep("-", level_data.width + 2)
  print(border)
  for i = 1, #level_data.content do
    local c = level_data.content:sub(i, i)
    word = word .. c
    if (i % level_data.width == 0) then
      print(word .. "|")
      word = "|"
    end
  end
  print(border)
end

local function generate_level_from_data(level_data)
  local initial_offset_x = -8.5
  local initial_offset_y = -4.5
  local number_of_level_types = 3
  local level_type = love.math.random(0, number_of_level_types - 1)
  local player_index = 1
  local max_players = 4

  for i = 0, #level_data.content - 1 do
    local x, y = i % level_data.width + initial_offset_x, math.floor(i / level_data.width) + initial_offset_y
    local char = level_data.content:sub(i + 1, i + 1)
    if not (char == level_data.empty_tile or char == level_data.player_tile) then
      local tile_type = nil
      if char == level_data.indestructible_tile then
        tile_type = 0
      else
        tile_type = tonumber(char)
      end
      if not (tile_type == nil) then
        walls(level, tile_type, level_type, vector2(x, y))
      end
    else
      if char == level_data.player_tile and player_index <= max_players then
        player(level, player_index, vector2(x, y), 5000 - player_index)
        player_index = player_index + 1
      end
    end
  end

  local r = level_type == 0 and 0.5 or 0.25
  local g = level_type == 2 and 0.5 or 0.25
  local b = level_type == 1 and 0.5 or 0.25
  camera.clear_color = { r, g, b, 1 }

  if level_type == 3 then
    camera.clear_color = { 46 / 255, 36 / 255, 47 / 255 }
  end
end

local function load()
  level = world()
  draw = entity_draw(level)

  level:add_system(input_system)
  level:add_system(input_velocity_system)
  level:add_system(collision_system)
  level:add_system(movement_system)
  level:add_system(animation_set_state_system)
  level:add_system(animate_system)

  local level_data = level_generator.generate_level_data()
  generate_level_from_data(level_data)

  game_event_manager.add_listener(GAME_EVENT_TYPES.UPDATE, on_update)
  game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_WORLD, on_draw)
  player_input.active_controller(CONTROLLER_TYPES.KEYBOARD)
end

return {
  name = "game",
  load = load,
  destroy = destroy,
}

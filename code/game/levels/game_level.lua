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
local player_attack_system = require "code.game.systems.player_attack_system"
local player_death_system = require "code.game.systems.player_death_system"
local destructible_wall_death_system = require "code.game.systems.destructible_wall_death_system"
local input_system = require "code.game.systems.input_system"
local input_velocity_system = require "code.game.systems.input_velocity_system"
local movement_system = require "code.game.systems.movement_system"
local animate_system = require "code.game.systems.animate_system"
local animation_set_state_system = require "code.game.systems.animation_set_state_system"
local collision_system = require "code.game.systems.collision_system"
local entity_draw = require "code.game.entity_draw"
local damager_system = require "code.game.systems.damager_system"
local destroy_timer_system = require "code.game.systems.destroy_timer_system"
local explosion_system = require "code.game.systems.explosion_system"
local gamestate_system = require "code.game.systems.gamestate_system"
local powerup_activator_system = require "code.game.systems.powerup_activator_system"
local powerup_spawner_system = require "code.game.systems.powerup_spawner_system"
local music_playlist_system = require "code.game.systems.music_playlist_system"

local level
local draw

local function on_update(dt)
  level:update(dt)
end

local function on_draw()
  draw:update(level)
end

local function destroy()
  level:destroy()

  game_event_manager.remove_listener(GAME_EVENT_TYPES.UPDATE, on_update)
  game_event_manager.remove_listener(GAME_EVENT_TYPES.DRAW_WORLD, on_draw)
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
  local initial_offset_x = -8
  local initial_offset_y = -5
  local number_of_level_types = 3
  local level_type = love.math.random(0, number_of_level_types - 1)
  local player_index = 1
  local max_players = table.get_size(player_input.get_active_controllers())
  local player_spawn_y_offset = 0.375

  background_image(level, "level/floor" .. level_type .. ".png", vector2(-8.5, -5.5))

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
        player(level, player_index, vector2(x, y - player_spawn_y_offset), 5000 - player_index)
        player_index = player_index + 1
      end
    end
  end
end

local function load()
  level = world()
  draw = entity_draw(level)
  camera:look_at(0.5, -0.5)

  level:add_system(input_system)
  level:add_system(player_death_system)
  level:add_system(destroy_timer_system)
  level:add_system(damager_system)
  level:add_system(explosion_system)
  level:add_system(destructible_wall_death_system)
  level:add_system(powerup_spawner_system)
  level:add_system(powerup_activator_system)
  level:add_system(input_velocity_system)
  level:add_system(animation_set_state_system)
  level:add_system(animate_system)
  level:add_system(collision_system)
  level:add_system(movement_system)
  level:add_system(player_attack_system)
  level:add_system(music_playlist_system)
  level:add_system(gamestate_system)

  local level_data = level_generator.generate_level_data()
  generate_level_from_data(level_data)

  game_event_manager.add_listener(GAME_EVENT_TYPES.UPDATE, on_update)
  game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_WORLD, on_draw)
end

return {
  name = "game",
  load = load,
  destroy = destroy,
}

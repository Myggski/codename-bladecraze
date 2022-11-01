local background_image = require "code.game.entities.background_image"
local walls = require "code.game.entities.walls"
local game_event_manager = require "code.engine.game_event.game_event_manager"
local player_input = require "code.game.player_input"
local world = require "code.engine.ecs.world"
local vector2 = require "code.engine.vector2"

-- systems
local player_attack_system = require "code.game.systems.player_attack_system"
local input_system = require "code.game.systems.input_system"
local input_velocity_system = require "code.game.systems.input_velocity_system"
local movement_system = require "code.game.systems.movement_system"
local animate_system = require "code.game.systems.animate_system"
local animation_set_state_system = require "code.game.systems.animation_set_state_system"
local collision_system = require "code.game.systems.collision_system"
local bubble_controller_system = require "code.game.systems.bubble_controller_system"
local target_movement_system = require "code.game.systems.target_movement_system"
local entity_draw = require "code.game.entity_draw"
local damager_system = require "code.game.systems.damager_system"
local destroy_timer_system = require "code.game.systems.destroy_timer_system"
local explosion_system = require "code.game.systems.explosion_system"

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

local function load()
  level = world()
  draw = entity_draw(level)

  level:add_system(input_system)
  level:add_system(input_velocity_system)
  level:add_system(animation_set_state_system)
  level:add_system(animate_system)
  level:add_system(collision_system)
  level:add_system(target_movement_system)
  level:add_system(movement_system)
  level:add_system(player_attack_system)
  level:add_system(bubble_controller_system)
  level:add_system(damager_system)
  level:add_system(destroy_timer_system)
  level:add_system(explosion_system)

  background_image(level, "level/press_start.png", vector2(-1.6875, -3.5))
  --background_image(level, "level/lobby_ready.png", vector2(4.5, -1.95))
  --background_image(level, "level/lobby_quit.png", vector2(-7.5, -1.95))

  walls(level, 2, vector2(5, -5))
  walls(level, 2, vector2(5, -3))
  walls(level, 2, vector2(5, -1))
  walls(level, 2, vector2(5, 1))
  walls(level, 2, vector2(5, 3))
  walls(level, 2, vector2(5, 5))

  walls(level, 2, vector2(3, -5))
  walls(level, 2, vector2(3, -3))
  walls(level, 2, vector2(3, -1))
  walls(level, 2, vector2(3, 1))
  walls(level, 2, vector2(3, 3))
  walls(level, 2, vector2(3, 5))

  walls(level, 2, vector2(1, -5))
  walls(level, 2, vector2(1, -3))
  walls(level, 2, vector2(1, -1))
  walls(level, 2, vector2(1, 1))
  walls(level, 2, vector2(1, 3))
  walls(level, 2, vector2(1, 5))

  walls(level, 2, vector2(-3, -5))
  walls(level, 2, vector2(-3, -3))
  walls(level, 2, vector2(-3, -1))
  walls(level, 2, vector2(-3, 1))
  walls(level, 2, vector2(-3, 3))
  walls(level, 2, vector2(-3, 5))

  walls(level, 2, vector2(-5, -5))
  walls(level, 2, vector2(-5, -3))
  walls(level, 2, vector2(-5, -1))
  walls(level, 2, vector2(-5, 1))
  walls(level, 2, vector2(-5, 3))
  walls(level, 2, vector2(-5, 5))

  walls(level, 2, vector2(-7, -5))
  walls(level, 2, vector2(-7, -3))
  walls(level, 2, vector2(-7, -1))
  walls(level, 2, vector2(-7, 1))
  walls(level, 2, vector2(-7, 3))
  walls(level, 2, vector2(-7, 5))

  game_event_manager.add_listener(GAME_EVENT_TYPES.UPDATE, on_update)
  game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_WORLD, on_draw)
end

return {
  load = load,
  destroy = destroy,
}

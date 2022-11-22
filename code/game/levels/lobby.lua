local background_image = require "code.game.entities.background_image"
local game_event_manager = require "code.engine.game_event.game_event_manager"
local world = require "code.engine.ecs.world"
local vector2 = require "code.engine.vector2"
-- systems
local input_system = require "code.game.systems.input_system"
local input_velocity_system = require "code.game.systems.input_velocity_system"
local movement_system = require "code.game.systems.movement_system"
local animate_system = require "code.game.systems.animate_system"
local animation_set_state_system = require "code.game.systems.animation_set_state_system"
local bubble_controller_system = require "code.game.systems.bubble_controller_system"
local target_movement_system = require "code.game.systems.target_movement_system"
local lobby_menu_system = require "code.game.systems.lobby_menu_system"
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
  level:destroy()

  game_event_manager.remove_listener(GAME_EVENT_TYPES.UPDATE, on_update)
  game_event_manager.remove_listener(GAME_EVENT_TYPES.DRAW_WORLD, on_draw)
end

local function load()
  level = world()
  draw = entity_draw(level)

  level:add_system(input_system)
  level:add_system(input_velocity_system)
  level:add_system(animation_set_state_system)
  level:add_system(animate_system)
  level:add_system(target_movement_system)
  level:add_system(collision_system)
  level:add_system(movement_system)
  level:add_system(bubble_controller_system)
  level:add_system(lobby_menu_system)

  background_image(level, "level/press_start.png", vector2(-3.375, -4.5), vector2(3.375, 1))

  game_event_manager.add_listener(GAME_EVENT_TYPES.UPDATE, on_update)
  game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_WORLD, on_draw)
end

return {
  name = "lobby",
  load = load,
  destroy = destroy,
}

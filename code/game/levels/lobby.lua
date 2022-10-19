local background_image = require "code.game.entities.background_image"
local game_event_manager = require "code.engine.game_event.game_event_manager"
local player_input = require "code.player.player_input"
local world = require "code.engine.ecs.world"

-- systems
local input_system = require "code.game.systems.input_system"
local input_velocity_system = require "code.game.systems.input_velocity_system"
local movement_system = require "code.game.systems.movement_system"
local animate_system = require "code.game.systems.animate_system"
local animation_set_state_system = require "code.game.systems.animation_set_state_system"
local bubble_controller_system = require "code.game.systems.bubble_controller_system"
local target_movement_system = require "code.game.systems.target_movement_system"
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

local function load()
  level = world()
  draw = entity_draw(level)

  level:add_system(input_system)
  level:add_system(input_velocity_system)
  level:add_system(movement_system)
  level:add_system(animation_set_state_system)
  level:add_system(animate_system)
  level:add_system(bubble_controller_system)
  level:add_system(target_movement_system)

  background_image(level, "level/press_start.png", { x = -1.6875, y = -3.5 })
  background_image(level, "level/lobby_ready.png", { x = 4.5, y = -1.95 })
  background_image(level, "level/lobby_quit.png", { x = -7.5, y = -1.95 })

  game_event_manager.add_listener(GAME_EVENT_TYPES.UPDATE, on_update)
  game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_WORLD, on_draw)
end

return {
  load = load,
  destroy = destroy,
}

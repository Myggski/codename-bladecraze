local background_image = require "code.game.entities.background_image"
local entity_draw = require "code.game.entity_draw"
local game_event_manager = require "code.engine.game_event.game_event_manager"
local player = require "code.game.entities.player"
local controller_highlight = require "code.game.entities.controller_highlight"
local player_input = require "code.player.player_input"
local world = require "code.engine.ecs.world"

-- systems
local input_system = require "code.game.systems.input_system"
local input_velocity_system = require "code.game.systems.input_velocity_system"
local movement_system = require "code.game.systems.movement_system"
local animate_system = require "code.game.systems.animate_system"
local animation_set_state_system = require "code.game.systems.animation_set_state_system"
local highlight_controller_System = require "code.game.systems.highlight_controller_System"

local level
local draw
local controller_highlights = {}

local function add_active_players()
  player(level, #player_input:get_active_controllers(), { x = 0, y = 0 })
end

local function add_available_joysticks()
  local position_x = -7.5 + (1.125 * #player_input.get_available_joysticks())
  table.insert(controller_highlights,
    controller_highlight(level, #controller_highlights + 1, CONTROLLER_TYPES.GAMEPAD,
      { x = position_x, y = 3.25 }))
end

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
  level:add_system(highlight_controller_System)

  background_image(level, "level/press_start.png", { x = -1.6875, y = -3.5 })
  background_image(level, "level/lobby_ready.png", { x = 4.5, y = -1.95 })
  background_image(level, "level/lobby_quit.png", { x = -7.5, y = -1.95 })

  table.insert(controller_highlights,
    controller_highlight(level, #controller_highlights + 1, CONTROLLER_TYPES.KEYBOARD, { x = -7.5, y = 3.25 }))

  player_input.add_on_player_activated(add_active_players)
  game_event_manager.add_listener(GAME_EVENT_TYPES.UPDATE, on_update)
  game_event_manager.add_listener(GAME_EVENT_TYPES.DRAW_WORLD, on_draw)
  game_event_manager.add_listener(GAME_EVENT_TYPES.JOYSTICK_ADDED, add_available_joysticks)
end

return {
  load = load,
  destroy = destroy,
}

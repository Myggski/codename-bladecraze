local system = require "code.engine.ecs.system"
local button = require "code.game.ui.button"
local background_image = require "code.game.entities.background_image"
local level_manager = require "code.engine.level_manager"
local vector2 = require "code.engine.vector2"
local player_input = require "code.game.player_input"
require "code.engine.constants.game_data"

local function quit_game()
  love.event.quit()
end

local function start_game()
  level_manager:load_level(2)
end

local function add_info_text(self)
  self.play_button_info = background_image(
    self:get_world(),
    "level/two_players.png",
    vector2(0, 2.5),
    vector2(3.375, 1)
  )
end

local lobby_menu_system = system(_, function(self, dt)
  if table.get_size(player_input.get_active_controllers()) >= GAME.MIN_PLAYERS then
    self.play_button:set_enabled(true)
    self.play_button_info:destroy()
  elseif self.play_button.enabled then
    self.play_button:set_enabled(false)
    add_info_text(self)
  end
end)

function lobby_menu_system:on_start()
  self.quit_button = button(16, 572, 192, 128, "Quit")
  self.quit_button:add_listener(BUTTON_EVENT_TYPES.RELEASE, quit_game)

  self.play_button = button(1072, 572, 192, 128, "Start")
  self.play_button:set_enabled(false)
  self.play_button:add_listener(BUTTON_EVENT_TYPES.RELEASE, start_game)
  add_info_text(self)
end

function lobby_menu_system:on_destroy()
  self.quit_button:remove_listener(BUTTON_EVENT_TYPES.RELEASE, quit_game)
  button:remove(self.quit_button)

  self.play_button:remove_listener(BUTTON_EVENT_TYPES.RELEASE, start_game)
  button:remove(self.play_button)
end

return lobby_menu_system

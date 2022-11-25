local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local gizmos = require "code.engine.debug.gizmos"
local level_manager = require "code.engine.level_manager"
local button = require "code.game.ui.button"
local vector2 = require "code.engine.vector2"

-- --[[
--   offset the topmost text and bottom most text by thne same value from the top and bottom
--   todo: update margins to adapt based on fontsize and screen size?
-- ]]
local screen_offset_top = 144
local screen_offset_button = screen_offset_top + 72
local button_padding = 144

local function replay()
  level_manager:reload_level()
end

local function menu()
  level_manager:load_level(1)
end

local function quit()
  love.event.quit()
end

local function draw_winner_header(title_text)
  local x = love.graphics.getWidth() / 2

  gizmos.draw_text(title_text, vector2(x, screen_offset_top + 8), 28, true, true, COLOR.BLACK, nil,
    gizmos.DRAW_SPACE.HUD)

  gizmos.draw_text(title_text, vector2(x, screen_offset_top), 28, true, true, nil, nil,
    gizmos.DRAW_SPACE.HUD)
end

local function handle_post_game(players)
  local text = "DRAW"
  local winner_entity = set.get_first(players)

  if winner_entity then
    local input = winner_entity[components.input]
    local winner_id = input.player_id

    winner_entity[components.input].enabled = false
    winner_entity[components.velocity] = vector2.zero()
    text = "Player " .. winner_id .. " Wins!"
  end

  draw_winner_header(text)
end

local input_filter = entity_query.filter(function(e)
  return e[components.input].enabled == false
end)

local state_query = entity_query.all(components.input).none(input_filter())

local gamestate_system = system(state_query, function(self, dt)
  local players, dead_players = self.players, self.dead_players

  if self.is_game_over then
    handle_post_game(players)
    return
  end

  self:for_each(function(entity)
    if entity[components.health] > 0 then
      set.add(players, entity)
    else
      set.delete(players, entity)
      table.insert(dead_players, entity)
    end
  end)

  local alive_count, dead_count = set.get_length(players), #dead_players
  local is_game_over = (alive_count == 0 and dead_count > 0) or (alive_count == 1 and dead_count > 0)

  if is_game_over then
    self.replay_button = button(512, screen_offset_button, 256, 128, "Replay")
    self.replay_button:add_listener(BUTTON_EVENT_TYPES.RELEASE, replay)

    self.menu_button = button(512, screen_offset_button + button_padding, 256, 128, "Menu")
    self.menu_button:add_listener(BUTTON_EVENT_TYPES.RELEASE, menu)

    self.quit_button = button(512, screen_offset_button + button_padding * 2, 256, 128, "Quit")
    self.quit_button:add_listener(BUTTON_EVENT_TYPES.RELEASE, quit)

    self.is_game_over = is_game_over
  end
end)

function gamestate_system:on_start()
  self.players = {} --set
  self.dead_players = {} --array
  self.is_game_over = false
  self.replay_button = nil
  self.menu_button = nil
  self.quit_button = nil
end

function gamestate_system:on_destroy()
  if self.quit_button then
    self.quit_button:remove_listener(BUTTON_EVENT_TYPES.RELEASE, quit)
    button:remove(self.quit_button)
  end

  if self.menu_button then
    self.menu_button:remove_listener(BUTTON_EVENT_TYPES.RELEASE, menu)
    button:remove(self.menu_button)
  end

  if self.replay_button then
    self.replay_button:remove_listener(BUTTON_EVENT_TYPES.RELEASE, replay)
    button:remove(self.replay_button)
  end
end

return gamestate_system

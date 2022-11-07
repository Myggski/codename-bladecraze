local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local gizmos = require "code.engine.debug.gizmos"
local level_manager = require "code.engine.level_manager"
local vector2 = require "code.engine.vector2"
local camera = require "code.engine.camera"
local function_manager = require "code.engine.function_manager"
local debug = require "code.engine.debug"
local state_query = entity_query.all(components.input)

local screen_offset_top = 240
local screen_offset_bot = -240
local title_margin = 20
local description_margin = 60

local menu_text = { "R - Restart", "M - Menu", "Q - Quit" }

local gamestate_system = system(state_query, function(self, dt)

  local time = love.timer.getTime()
  local players, dead_players = self.players, self.dead_players

  self:for_each(function(entity)
    if entity:is_alive() then
      set.add(players, entity)
    else
      set.delete(players, entity)
      table.insert(dead_players, entity)
    end
  end)

  local alive_count = set.get_length(players)
  local dead_count = #dead_players

  if alive_count > 1 or dead_count == 0 then
    return
  end

  local x = love.graphics.getWidth() / 2
  local text = ""
  if alive_count == 0 then
    text = "DRAW"
  else
    local winner_entity = set.get_first(players)
    local input = winner_entity[components.input]
    if input.enabled then
      self.winner_id = input.player_id
      winner_entity[components.input].enabled = false
      winner_entity[components.velocity] = vector2.zero()
    end
    text = "Player " .. self.winner_id .. " Wins!"
  end

  gizmos.draw_text(text, vector2(x, screen_offset_top), 28, true, true, nil, nil,
    gizmos.DRAW_SPACE.HUD)

  local initial_offset = love.graphics.getHeight() + screen_offset_bot
  for i = #menu_text, 1, -1 do
    local y_offset = initial_offset - description_margin * (#menu_text - i)
    gizmos.draw_text(menu_text[i], vector2(x, y_offset),
      16, true, true, nil, nil,
      gizmos.DRAW_SPACE.HUD)
  end

  --TODO: make this work with controllers as well?
  if love.keyboard.isDown("r") then
    level_manager:reload_level()
  elseif love.keyboard.isDown("m") then
    level_manager:load_level(1)
  elseif love.keyboard.isDown("q") then
    love.event.quit()
  end

end)
function gamestate_system:on_start()
  self.players = {} --set
  self.dead_players = {} --array
  self.winner_id = 0
  self.is_game_over = false
  self.restart_function_object = nil
end

return gamestate_system

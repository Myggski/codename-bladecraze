local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"

local state_query = entity_query.all(components.input)

local players = {} --set
local dead_players = {} --array

local gamestate_system = system(state_query, function(self, dt)
  local time = love.timer.getTime()
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

  if alive_count > 2 then
    return
  end
  if alive_count == 0 then
    print("DRAW!")
  elseif alive_count == 1 and dead_count > 0 then
    print("player id #" .. set.get_first(players):get_id() .. " is the winner!")
  end
end)

return gamestate_system

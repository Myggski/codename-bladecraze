local game_event_manager = require "code.engine.game_event.game_event_manager"
local execution_table = {}

local function execute_after_seconds(func, wait_time, ...)
  local function_object = { func = func, wait_time = love.timer.getTime() + wait_time, args = table.pack_all(...) }
  table.insert(execution_table, function_object)
  return function_object
end

local function update(_)
  local time = love.timer.getTime()
  for i = #execution_table, 1, -1 do
    local value = execution_table[i]
    if time >= value.wait_time then
      value.func(table.unpack_all(value.args))
      table.remove(execution_table, i)
    end
  end
end

game_event_manager.add_listener(GAME_EVENT_TYPES.UPDATE, update)

return { execute_after_seconds = execute_after_seconds }

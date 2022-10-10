local game_event_manager = require "code.engine.game_event.game_event_manager"
local execution_table = {}

local function execute_after_seconds(func, wait_time, ...)
  table.insert(execution_table, { func = func, wait_time = wait_time, args = table.pack_all(...) })
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

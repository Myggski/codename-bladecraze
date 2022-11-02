local gizmos = require "code.engine.debug.gizmos"

local get_execution_time = function(func, ...)
  local start = love.timer.getTime()
  func(...)
  return love.timer.getTime() - start
end

local print_execution_time = function(func_name, func, ...)
  print(string.format("%s executed in %fms", func_name, get_execution_time(func, ...) * 1000))
end

local print_execution_time_seconds = function(func_name, func, ...)
  print(string.format("%s executed in %es", func_name, get_execution_time(func, ...)))
end

local track_function_call_time = function(number_of_calls)
  local total_nr_of_calls = 0
  local track_data = {
    lowest = 9999999,
    highest = -9999999,
    timers = {},
    avg = 0,
  }

  return function(func_name, func, ...)
    total_nr_of_calls = total_nr_of_calls + 1

    if total_nr_of_calls >= number_of_calls then
      track_data.avg = math.average(track_data.timers)
      print(string.format("%s execution info %i calls - lowest %fms, highest: %fms, avg: %fms", func_name,
        total_nr_of_calls,
        track_data.lowest * 1000,
        track_data.highest * 1000, track_data.avg * 1000))

      total_nr_of_calls = 0
      track_data.lowest = 999999
      track_data.highest = -999999
      track_data.timers = {}
      track_data.avg = 0
    end

    local time = get_execution_time(func, ...)

    if time < track_data.lowest then
      track_data.lowest = time
    end

    if time > track_data.highest then
      track_data.highest = time
    end

    table.insert(track_data.timers, time)
  end
end

local debug = {
  gizmos = gizmos,
  get_execution_time = get_execution_time,
  print_execution_time = print_execution_time,
  print_execution_time_seconds = print_execution_time_seconds,
  track_function_call_time = track_function_call_time,
}

return debug

local gizmos = require "code.utilities.debug.gizmos"

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

local debug = {
  gizmos = gizmos,
  get_execution_time = get_execution_time,
  print_execution_time = print_execution_time,
  print_execution_time_seconds = print_execution_time_seconds,
}

return debug

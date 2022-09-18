local get_execution_time = function(func, ...)
  local start = love.timer.getTime()
  func(...)
  return love.timer.getTime() - start
end

local print_execution_time = function(func_name, func, ...)
  print(string.format("%s executed in %e seconds", func_name, get_execution_time(func, ...)))
end

local debug = {
  gizmos = require "code.utilities.debug.gizmos",
  get_execution_time = get_execution_time,
  print_execution_time = print_execution_time,
}

return debug

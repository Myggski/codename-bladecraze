local vector2 = {}
vector2.__index = vector2

--[[
  resource: https://github.com/vrld/hump/blob/master/vector.lua,
  changes: made zero, one etc functions instead of local variables
  as attempts to use them on multiple objects would override
]]

local function create(x, y)
  return setmetatable({ x = x or 0, y = y or 0 }, vector2)
end

local function get_value(value)
  local x, y = 0, 0

  if type(value) == "table" then
    x, y = value.x or 0, value.y or 0
  elseif type(value) == "number" then
    x, y = value, value
  end

  return x, y
end

function vector2:__add(value)
  local x, y = get_value(value)

  self.x, self.y = self.x + x, self.y + y
  return self
end

function vector2:__sub(value)
  local x, y = get_value(value)

  self.x, self.y = self.x - x, self.y - y
  return self
end

function vector2:__mul(value)
  local x, y = get_value(value)

  self.x, self.y = self.x * x, self.y * y
  return self
end

function vector2:__div(value)
  local x, y = get_value(value)

  self.x, self.y = self.x / x, self.y / y
  return self
end

-- TODO: Find better name
-- When you want the value but not the table reference
function vector2:value()
  return create(self.x, self.y)
end

return setmetatable({
  create = create,
  zero = function(_) return create(0, 0) end,
  one = function(_) return create(1, 1) end,
  up = function(_) return create(0, -1) end,
  down = function(_) return create(0, 1) end,
  left = function(_) return create(-1, 0) end,
  right = function(_) return create(1, 0) end,
}, {
  __call = function(_, ...) return create(...) end,
})

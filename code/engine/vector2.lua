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

  return create(self.x + x, self.y + y)
end

function vector2:__sub(value)
  local x, y = get_value(value)

  return create(self.x - x, self.y - y)
end

function vector2:__mul(value)
  local x, y = get_value(value)

  return create(self.x * x, self.y * y)
end

function vector2:__div(value)
  local x, y = get_value(value)

  return create(self.x / x, self.y / y)
end

function vector2:__eq(value)
  return self.x == value.x and self.y == value.y
end

function vector2:copy(vector)

end

return setmetatable({
  create = create,
  zero = function(_) return create(0, 0) end,
  one = function(_) return create(1, 1) end,
  up = function(_) return create(0, -1) end,
  down = function(_) return create(0, 1) end,
  left = function(_) return create(-1, 0) end,
  right = function(_) return create(1, 0) end,
  copy = function(vector) return create(vector.x, vector.y) end,
}, {
  __call = function(_, ...) return create(...) end,
})

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

function vector2:__add(other_vector)
  return create(self.x + other_vector.x, self.y + other_vector.y)
end

function vector2:__sub(other_vector)
  return create(self.x - other_vector.x, self.y - other_vector.y)
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

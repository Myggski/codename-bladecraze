local vector2 = {}
vector2.__index = vector2


--[[resource: https://github.com/vrld/hump/blob/master/vector.lua]]

local function create(x, y)
  return setmetatable({ x = x or 0, y = y or 0 }, vector2)
end

local zero = create(0, 0)
local one = create(1, 1)
local up = create(0, -1)
local down = create(0, 1)


function vector2:__add(other_vector)
  return create(self.x + other_vector.x, self.y + other_vector.y)
end

function vector2:__sub(other_vector)
  return create(self.x - other_vector.x, self.y - other_vector.y)
end

return setmetatable({
  create = create,
  zero = zero,
  one = one,
  up = up,
  down = down,
}, {
  __call = function(_, ...) return create(...) end,
})

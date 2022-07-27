local rectangle = {
  x = nil,
  y = nil,
  w = nil,
  h = nil
}

function rectangle:create(x, y, w, h)
  local obj = {}
  setmetatable(obj, self)

  self.__index = self
  self.x = x
  self.y = y
  self.w = w
  self.h = h

  return obj
end

function rectangle:is_inside(x, y)
  return self.x <= x and self.y <= y and (self.x + self.w) >= x and (self.y + self.h) >= y
end

return rectangle
local rectangle = {}

function rectangle:create(x, y, w, h)
  self.__index = self
  return setmetatable({
      x = x,
      y = y,
      w = w,
      h = h,
  }, self)
end

function rectangle:create2(position, bounds)
  self.__index = self
  local x, y = unpack(position)
  local w, h = unpack(bounds)
  return rectangle:create(x,y,w,h)
end

function rectangle:is_inside(x, y)
  return self.x <= x and self.y <= y and (self.x + self.w) >= x and (self.y + self.h) >= y
end

function rectangle:overlap_box(other_box)
  return(
  self.x < other_box.x + other_box.w and
  self.x + self.w > other_box.x and
  self.y < other_box.y + other_box.h and
  self.y + self.h > other_box.y)
end

return rectangle

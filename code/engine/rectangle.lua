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

function rectangle:is_inside(x, y)
  return self.x <= x and self.y <= y and (self.x + self.w) >= x and (self.y + self.h) >= y
end

function rectangle:center_x()
  return self.x + self.w / 2
end

function rectangle:center_y()
  return self.y + self.h / 2
end

function rectangle:center()
  return self:center_x(), self:center_y()
end

function rectangle:overlap(x, y, w, h)
  return (
      self.x <= x + w and
          self.x + self.w >= x and
          self.y <= y + h and
          self.y + self.h >= y)
end

return rectangle

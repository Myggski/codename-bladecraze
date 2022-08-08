local camera = require("code.engine.camera")
local rectangle = {}
local scale = camera:get_scale()

function rectangle:create(x, y, w, h)
  self.__index = self
  return setmetatable({
      x = x,
      y = y,
      w = w,
      h = h,
  }, self)
end

function rectangle:get_scaled_width()
  return self.w * scale.x
end

function rectangle:get_scaled_height()
  return self.h * scale.y
end

function rectangle:get_width()
  return self.w
end

function rectangle:get_height()
  return self.h
end

function rectangle:is_inside(x, y)
  return self.x <= x and self.y <= y and (self.x + self:get_scaled_width()) >= x and (self.y + self:get_scaled_height()) >= y
end

function rectangle:overlap(x,y,w,h)
  return(
  self.x < x + w and
  self.x + self.w > x and
  self.y < y + h and
  self.y + self.h > y)
end

return rectangle

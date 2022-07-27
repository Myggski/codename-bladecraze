local rectangle = require './code/core/rectangle'

local button = {
  rectangle = nil,
  image = nil,
  callbacks = {},
}

function button:init()
  function love.mousepressed(x, y, button, istouch)
    if button == 1 and rectangle:is_inside(x, y) then -- Versions prior to 0.10.0 use the MouseConstant 'l'
      for index, callback in pairs(self.callbacks) do
        callback()
       end
    end
  end
end

function button:add_listener(callback)
  table.insert(self.callbacks, #self.callbacks + 1, callback)
end

function button:remove_listener(callback)
  local index = nil

  for i, callback in pairs(self.callbacks) do
    index = i - 1
  end

  if (index) then
    table.remove(self.callbacks, index)
  end
end

function button:create(rectangle, image)
  local obj = {}
  setmetatable(obj, self)
  
  self.__index = self
  self.rectangle = rectangle
  self.image = image
  self:init()

  return obj
end

return button
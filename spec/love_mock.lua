local love_mock = {}
local fake_love_default = {
  graphics = {},
}

function love_mock:set_screen_size(width, height)
  self.fake_love.graphics.getWidth = function()
    return width
  end

  self.fake_love.graphics.getHeight = function()
    return height
  end

  return self
end

function love_mock.init(self)
  self.fake_love = fake_love_default

  return self
end

function love_mock:build()
  _G.love = self.fake_love

  return self.fake_love
end

function love_mock:reset()
  self.fake_love = nil
end

return setmetatable(love_mock, {
  __index = love_mock,
  __call = love_mock.init,
})

--[[
  PIXEL COORDINATES = love.mouse.getPosition() returns pixel coordinates
  top-left = (0, 0), bottom-right = screen resolution, e.g. 1920x1080 or 3440x1440 and so on.

  VIRTUAL RESOLUTION = Screen resolution / Scale. e.g. 1920x1080 / 6 = 320x180.
  We're dealing with small images, and scaling the canvas up to make the images look larger than it actually is.

  WORLD COORDINATES = Is the position of a entity or thing in the game world.
  SCREEN COORDINATES = Pixel coordinates on the screen that is upscaled same as the images.
]]

local camera = {
  --[[
    resolution can be changed to
    GAME_WIDTH and GAME_HEIGHT globals
    ]]
  virtual_resolution_x = 213.33,
  virtual_resolution_y = 120,
  x = 0,
  y = 0,
  scale = 6,
  current_scale = 6,
  canvas_game = {},
  is_fullscreen = false,
}
camera.__index = camera

-- Returns virtual screen size (actual screen size / self.scale)
function camera:get_screen_size()
  return self.virtual_resolution_x, self.virtual_resolution_y
end

-- Returns actual screen pixel coordinates to game virtual coordinates
function camera:screen_coordinates(pixel_x, pixel_y)
  return pixel_x / self.scale, pixel_y / self.scale
end

-- Returns centered screen world coordinates
function camera:world_coordinates(screen_x, screen_y)
  local width, height = self:get_screen_size()

  local centered_x, centered_y = (screen_x - width / 2), (screen_y - height / 2)
  return centered_x + self.x, centered_y + self.y
end

-- Converts world coordinates to screen coordinates
function camera:world_to_screen(world_x, world_y)
  return (world_x - self.x + (self.virtual_resolution_x / 2)),
      (world_y - self.y + (self.virtual_resolution_y / 2))
end

-- Converts screen coordinates to world coordinates
function camera:screen_to_world(screen_x, screen_y)
  return (screen_x + self.x - (self.virtual_resolution_x / 2)),
      (screen_y + self.y - (self.virtual_resolution_y / 2))
end

-- Returns the mouse position in the world
function camera:mouse_position_world() return self:world_coordinates(self:screen_coordinates(love.mouse.getPosition())) end

-- Returns the mouse position on the screen
function camera:mouse_position_screen() return self:screen_coordinates(love.mouse.getPosition()) end

-- Returns camera position
function camera:get_position()
  return self.x, self.y
end

-- Sets what the camera should look at
function camera:look_at(world_x, world_y)
  self.x, self.y = world_x, world_y
end

-- Is outside of cameras view
function camera:is_outside(world_x, world_y)
  local half_width, half_height = self.virtual_resolution_x / 2, self.virtual_resolution_y / 2
  return world_x < self.x - half_width or world_x > self.x + half_width or world_y < self.y - half_height or
      world_y > self.y + half_height
end

function camera:start_draw_world()
  love.graphics.setCanvas(camera.canvas_game)
  love.graphics.clear(0, 0, 0, 0)

  love.graphics.push()
  local canvas_x, canvas_y = self.virtual_resolution_x / 2, self.virtual_resolution_y / 2
  love.graphics.translate(math.round(canvas_x), math.round(canvas_y)) -- Center the origin
  love.graphics.translate(math.round(-self.x), math.round(-self.y)) -- Sets the camera position
end

function camera:stop_draw_world()
  love.graphics.pop()
end

function camera:toggle_fullscreen()
  self.is_fullscreen = love.window.setFullscreen(not self.is_fullscreen, "desktop")
end

function camera:load()
  self:toggle_fullscreen()

  if self.is_fullscreen then
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    self.virtual_resolution_x, self.virtual_resolution_y = width / self.scale, height / self.scale
    self.canvas_game = love.graphics.newCanvas(self.virtual_resolution_x, self.virtual_resolution_y)
    self.canvas_game:setFilter("nearest", "nearest")
  end
end

return camera

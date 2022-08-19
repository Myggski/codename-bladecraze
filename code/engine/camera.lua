--[[
  PIXEL COORDINATES = love.mouse.getPosition() returns pixel coordinates
  top-left = (0, 0), bottom-right = screen resolution, e.g. 1920x1080 or 3440x1440 and so on.

  VIRTUAL RESOLUTION = Screen resolution / Scale. e.g. 1920x1080 / 6 = 320x180.
  We're dealing with small images, and scaling the canvas up to make the images look larger than it actually is.

  WORLD COORDINATES = Is the position of a entity or thing in the game world.
  SCREEN COORDINATES = Pixel coordinates on the screen that is upscaled same as the images.
]]

local camera = {
  x = 0,
  y = 0,
  scale = 6,
  default_scale = 6,
  canvas = {},
  canvas_hud = {},
  is_fullscreen = false,
  zoom = 0,
  follow_targets = {},
}
camera.__index = camera

-- Get screen size with scale and zoom
function camera:get_screen_game_size()
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()
  return width / (self.scale + self.zoom), height / (self.scale + self.zoom)
end

function camera:get_screen_game_hud_diff()
  return self.scale / (self.scale + self.zoom)
end

-- Returns actual screen pixel coordinates to game virtual coordinates
function camera:screen_coordinates(pixel_x, pixel_y)

  return pixel_x / (self.scale), pixel_y / (self.scale)
end

-- Returns centered screen world coordinates
function camera:world_coordinates(screen_x, screen_y)
  local width, height = self:get_screen_game_size()

  local centered_x, centered_y = (screen_x - width / 2), (screen_y - height / 2)
  return centered_x + self.x, centered_y + self.y
end

-- Returns camera position
function camera:get_position() return self.x, self.y end

function camera:follow(target)
  table.insert(self.follow_targets, target)
end

function camera:unfollow(target)
  local index = table.index_of(self.follow_targets, target)

  if not index == nil then
    table.remove(self.follow_targets, index)
  end
end

-- Sets what the camera should look at
function camera:look_at(world_x, world_y) self.x, self.y = world_x, world_y end

function camera:try_zoom(is_outside, dt)
  if is_outside and self.zoom > -2 then
    self:zoom_game(-dt)
  end
end

-- Returns the mouse position in the world
function camera:mouse_position_world()
  local pixel_x, pixel_y = love.mouse.getPosition()
  local screen_x, screen_y = self:screen_coordinates(pixel_x, pixel_y);
  return self:world_coordinates(screen_x * self:get_screen_game_hud_diff(), screen_y * self:get_screen_game_hud_diff())
end

-- Returns the mouse position on the screen
function camera:mouse_position_screen() return self:screen_coordinates(love.mouse.getPosition()) end

function camera:toggle_fullscreen() self.is_fullscreen = love.window.setFullscreen(not self.is_fullscreen, "desktop") end

-- Is outside of cameras view
function camera:is_outside(world_x, world_y)
  local width, height = camera:get_screen_game_size()
  local half_width, half_height = width / 2, height / 2
  return world_x < self.x - half_width or world_x > self.x + half_width or world_y < self.y - half_height or
      world_y > self.y + half_height
end

-- Preparing to draw the game world
function camera:start_draw_world()
  love.graphics.setCanvas(camera.canvas)
  love.graphics.clear(0, 0, 0, 0)
  love.graphics.push()

  local width, height = camera:get_screen_game_size()
  local canvas_x, canvas_y = width / 2, height / 2
  love.graphics.translate(math.round(canvas_x), math.round(canvas_y)) -- Center the origin
  love.graphics.translate(math.round(-self.x), math.round(-self.y)) -- Sets the camera position
end

-- Resets everything after drawing the game world
function camera:stop_draw_world()
  love.graphics.pop()
  love.graphics.setCanvas()
  love.graphics.draw(camera.canvas, 0, 0, 0, camera.scale + camera.zoom) -- Draw canvas upscaled
end

-- Preparing to draw the game hud
function camera:start_draw_hud()
  love.graphics.setCanvas(camera.canvas_hud)
  love.graphics.clear(0, 0, 0, 0)
end

-- Resets everything after drawing the hud
function camera:stop_draw_hud()
  love.graphics.setCanvas()
  love.graphics.draw(camera.canvas_hud, 0, 0, 0, camera.scale) -- Draw canvas upscaled
end

function camera:set_canvas_game(width, height)
  self.canvas = love.graphics.newCanvas(width, height)
  self.canvas:setFilter("nearest", "nearest")
end

function camera:set_canvas_hud(width, height)
  self.canvas_hud = love.graphics.newCanvas(width, height)
  self.canvas_hud:setFilter("nearest", "nearest")
end

function camera:set_canvas()
  local width, height = camera:get_screen_game_size()

  self:set_canvas_game(width, height)
  self:set_canvas_hud(width, height)
end

function camera:zoom_game(zoom_value)
  self.zoom = self.zoom + zoom_value

  self:set_canvas_game(self:get_screen_game_size())
end

function camera:set_camera_position(dt)
  local number_of_targets = table.get_size(self.follow_targets)
  local position_x, position_y = 0, 0
  local is_outside = false

  for index = 1, number_of_targets do
    local target = self.follow_targets[index]
    position_x = position_x + target.center_position.x
    position_y = position_y + target.center_position.y

    is_outside = is_outside or camera:is_outside(target.center_position.x, target.center_position.y)
  end

  position_x = position_x / number_of_targets
  position_y = position_y / number_of_targets

  self:try_zoom(is_outside, dt)
  self:look_at(position_x, position_y)
end

function camera:load()
  self:toggle_fullscreen()

  if self.is_fullscreen then
    self:set_canvas()
  end
end

function camera:update(dt)
  if #self.follow_targets > 0 then
    self:set_camera_position(dt)
  end
end

return camera

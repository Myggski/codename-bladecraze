local game_event_manager = require("code.engine.game_event.game_event_manager")
local camera = {
  --[[
    resolution can be changed to
    GAME_WIDTH and GAME_HEIGHT globals
    ]]
  logical_resolution_x = 213.33,
  logical_resolution_y = 120,
  x = 0,
  y = 0,
  scale = 6,
  current_scale = 6,
  canvas_game = {},
  canvas_hud = {},
  is_fullscreen = false,
}
camera.__index = camera

-- Returns coordinates without the scaling and camera position
function camera:screen_coordinates(x, y)
  return x / self.scale, y / self.scale
end

-- Returns actual size of screen
function camera:get_screen_size()
  return self.logical_resolution_x * self.scale, self.logical_resolution_y * self.scale
end

-- Returns coordinates without scaling but adding camera position
function camera:world_coordinates(x, y)
  local width, height = self:get_screen_size()

  local centered_x, centered_y = (x - width / 2) / self.scale, (y - height / 2) / self.scale
  return centered_x + self.x, centered_y + self.y
end

-- Returns the mouse position in the world
function camera:mouse_position_world()
  local mouse_x, mouse_y = love.mouse.getPosition()
  return self:world_coordinates(mouse_x, mouse_y)
end

-- Returns the mouse position on the screen
function camera:mouse_position_screen()
  local mouse_x, mouse_y = love.mouse.getPosition()
  return self:screen_coordinates(mouse_x, mouse_y)
end

-- Returns camera position
function camera:get_position()
  return self.x, self.y
end

-- Sets what the camera should look at
function camera:look_at(x, y)
  self.x, self.y = x, y
end

-- Is outside of cameras view
function camera:is_outside(x, y)
  local half_width, half_height = self.logical_resolution_x / 2, self.logical_resolution_y / 2
  return x < self.x - half_width or x > self.x + half_width or y < self.y - half_height or y > self.y + half_height
end

function camera:start_draw_world()
  love.graphics.setCanvas(camera.canvas_game)
  love.graphics.clear(0, 0, 0, 0) -- Resets canvas

  love.graphics.push()
  local canvas_x, canvas_y = self.logical_resolution_x / 2, self.logical_resolution_y / 2
  love.graphics.translate(math.round(canvas_x), math.round(canvas_y)) -- Center the origin
  love.graphics.translate(math.round(-self.x), math.round(-self.y)) -- Sets the camera position
end

function camera:stop_draw_world()
  love.graphics.pop()
  love.graphics.setCanvas()
  love.graphics.draw(camera.canvas_game, 0, 0, 0, camera.scale, camera.current_scale) -- Draw canvas upscaled
end

function camera:start_draw_hud()
  love.graphics.setCanvas(camera.canvas_hud)
  love.graphics.clear(0, 0, 0, 0) -- Resets canvas
end

function camera:stop_draw_hud()
  love.graphics.setCanvas()
  love.graphics.draw(camera.canvas_hud, 0, 0, 0, camera.scale, camera.scale) -- Draw canvas upscaled
end

function camera:toggle_fullscreen()
  self.is_fullscreen = love.window.setFullscreen(not self.is_fullscreen, "desktop")
end

function camera:load()
  self:toggle_fullscreen()

  if self.is_fullscreen then
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    self.logical_resolution_x, self.logical_resolution_y = width / self.scale, height / self.scale
    self.canvas_game = love.graphics.newCanvas(self.logical_resolution_x, self.logical_resolution_y)
    self.canvas_hud = love.graphics.newCanvas(self.logical_resolution_x, self.logical_resolution_y)
    self.canvas_game:setFilter("nearest", "nearest")
    self.canvas_hud:setFilter("nearest", "nearest")
  end
end

return camera

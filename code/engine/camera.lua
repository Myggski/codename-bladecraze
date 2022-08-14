local game_event_manager = require("code.engine.game_event.game_event_manager")
local camera = {
  --[[
    resolution can be changed to
    GAME_WIDTH and GAME_HEIGHT globals
    ]]
  visual_resolution_x = 384,
  visual_resolution_y = 208,
  x = 0,
  y = 0,
  canvas = {},
}
camera.__index = camera

function camera:get_scale()
  return love.graphics.getWidth() / self.visual_resolution_x, love.graphics.getHeight() / self.visual_resolution_y
end

-- Returns coordinates without the scaling and camera position
function camera:screen_coordinates(x, y)
  local scale_x, scale_y = self:get_scale()
  return x / scale_x, y / scale_y
end

-- Returns coordinates without scaling but adding camera position
function camera:world_coordinates(x, y)
  local scale_x, scale_y = self:get_scale()
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()

  local centered_x, centered_y = (x - width / 2) / scale_x, (y - height / 2) / scale_y
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
function camera:lookAt(x, y)
  self.x, self.y = x, y
end

function camera:attach()
  local canvas_x, canvas_y = self.visual_resolution_x / 2, self.visual_resolution_y / 2
  love.graphics.push()
  love.graphics.translate(math.round(canvas_x), math.round(canvas_y)) -- Center the origin
  love.graphics.translate(math.round(-self.x), math.round(-self.y)) -- Sets the camera position
end

function camera:detatch()
  love.graphics.pop()
end

function camera:load()
  self.canvas = love.graphics.newCanvas(self.visual_resolution_x, self.visual_resolution_y)
  self.canvas:setFilter("nearest", "nearest")
end

function camera:draw()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear(0, 0, 0, 0) -- Resets canvas

  camera:attach()
  game_event_manager.invoke(GAME_EVENT_TYPES.DRAW_WORLD, self.canvas)
  camera:detatch()

  game_event_manager.invoke(GAME_EVENT_TYPES.DRAW_HUD, camera.canvas)

  love.graphics.setCanvas()
  love.graphics.draw(self.canvas, 0, 0, 0, self:get_scale()) -- Draw canvas upscaled
end

return camera

--[[
  PIXEL COORDINATES = love.mouse.getPosition() returns pixel coordinates
  top-left = (0, 0), bottom-right = screen resolution, e.g. 1920x1080 or 3440x1440 and so on.

  VIRTUAL RESOLUTION = Screen resolution / Scale. e.g. 1920x1080 / 6 = 320x180.
  We're dealing with small images, and scaling the canvas up to make the images look larger than it actually is.

  WORLD COORDINATES = Is the position of a entity or thing in the game world.
  SCREEN COORDINATES = Pixel coordinates on the screen that is upscaled same as the images.
]]

ZOOM_MIN = -3
ZOOM_MAX = 0
ZOOM_ANIMATION_STEP = 0.5
ZOOM_ANIMATION_SPEED = 0.025

ZOOM_ANIMATION_STATE = {
  NONE = 0,
  IN = 1,
  IN_HORIZONTALLY = 1,
  OUT = 2,
  OUT_HORIZONTALLY = 2,
}

local camera = {
  x = 0,
  y = 0,
  scale = 6,
  canvas_game = {},
  canvas_hud = {},
  delta_time = 0,
  is_fullscreen = false,
  follow_targets = {},
  furthest_target_x = {},
  furthest_target_y = {},
  zoom = 0,
  zoom_animation_coroutine = nil,
}
camera.__index = camera

-- Get screen size with scale and zoom
function camera:get_screen_game_size()
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()

  return width / (self.scale + self.zoom), height / (self.scale + self.zoom)
end

function camera:get_screen_game_half_size()
  local width, height = self:get_screen_game_size()

  return width / 2, height / 2
end

function camera:get_aspect_ratio()
  local width, height = camera:get_screen_game_size()

  return width / height
end

-- Returns scale diff between game and hud
function camera:get_screen_game_hud_diff() return self.scale / (self.scale + self.zoom) end

-- Returns actual screen pixel coordinates to game virtual coordinates
function camera:screen_coordinates(pixel_x, pixel_y) return pixel_x / self.scale, pixel_y / self.scale end

-- Returns centered screen world coordinates
function camera:world_coordinates(screen_x, screen_y)
  local width, height = self:get_screen_game_size()
  local centered_x, centered_y = (screen_x - width / 2), (screen_y - height / 2)

  return centered_x + self.x, centered_y + self.y
end

-- Adds target to follow
function camera:follow(target) table.insert(self.follow_targets, target) end

-- Removes target to follow
function camera:unfollow(target)
  local index = table.index_of(self.follow_targets, target)

  if not (index == nil) then
    table.remove(self.follow_targets, index)
  end
end

-- Returns camera position in game world
function camera:get_position() return self.x, self.y end

-- Returns the mouse position on the screen
function camera:mouse_position_screen() return self:screen_coordinates(love.mouse.getPosition()) end

-- Returns the mouse position in the world
function camera:mouse_position_world()
  local pixel_x, pixel_y = love.mouse.getPosition()
  local screen_x, screen_y = self:screen_coordinates(pixel_x, pixel_y);

  return self:world_coordinates(screen_x * self:get_screen_game_hud_diff(), screen_y * self:get_screen_game_hud_diff())
end

-- Turns on or off fullscreen
function camera:toggle_fullscreen() self.is_fullscreen = love.window.setFullscreen(not self.is_fullscreen, "desktop") end

-- Sets what the camera should look at
function camera:look_at(world_x, world_y) self.x, self.y = world_x, world_y end

-- Returns true or false if its outside of camera in both x and y axis
function camera:is_outside_directions(rectangle_x, rectangle_y, margin_percentage)
  margin_percentage = margin_percentage or 0

  local half_width, half_height = camera:get_screen_game_half_size()
  half_width = half_width - (half_width * margin_percentage) / self:get_aspect_ratio()
  half_height = half_height - (half_height * margin_percentage)

  local is_outside_x = rectangle_x.x < self.x - half_width or rectangle_x.x + rectangle_x.w > self.x + half_width
  local is_outside_y = rectangle_y.y < self.y - half_height or rectangle_y.y + rectangle_y.h > self.y + half_height

  return is_outside_x, is_outside_y
end

-- Returns true if its outside in any direction
function camera:is_outside(target_rectangle, margin_percentage)
  local is_outside_x, is_outside_y = self:is_outside_directions(target_rectangle, target_rectangle, margin_percentage)

  return is_outside_x or is_outside_y
end

-- Preparing to draw the game world
function camera:start_draw_world()
  love.graphics.setCanvas(camera.canvas_game)
  love.graphics.clear(0, 0, 0, 0)
  love.graphics.push()

  local half_width, half_height = camera:get_screen_game_half_size()
  love.graphics.translate(math.round(half_width), math.round(half_height)) -- Center the origin
  love.graphics.translate(math.round(-self.x), math.round(-self.y)) -- Sets the camera position
end

-- Resets everything after drawing the game world
function camera:stop_draw_world()
  love.graphics.pop()
  love.graphics.setCanvas()
  love.graphics.draw(camera.canvas_game, 0, 0, 0, camera.scale + camera.zoom)
end

-- Preparing to draw the game hud
function camera:start_draw_hud()
  love.graphics.setCanvas(camera.canvas_hud)
  love.graphics.clear(0, 0, 0, 0)
end

-- Resets everything after drawing the hud
function camera:stop_draw_hud()
  love.graphics.setCanvas()
  love.graphics.draw(camera.canvas_hud, 0, 0, 0, camera.scale)
end

function camera:set_canvas_game(width, height)
  self.canvas_game = love.graphics.newCanvas(width, height)
  self.canvas_game:setFilter("nearest", "nearest")
end

function camera:set_canvas_hud(width, height)
  self.canvas_hud = love.graphics.newCanvas(width, height)
  self.canvas_hud:setFilter("nearest", "nearest")
end

function camera:get_zoom_animation_state(is_inside_outer, is_inside_inner)
  local animation_state = ZOOM_ANIMATION_STATE.NONE

  if self.zoom >= ZOOM_MIN and is_inside_outer then
    animation_state = ZOOM_ANIMATION_STATE.OUT
  elseif self.zoom < ZOOM_MAX and not is_inside_inner then
    animation_state = ZOOM_ANIMATION_STATE.IN
  end

  return animation_state
end

function camera:try_zoom()
  self.furthest_target_x, self.furthest_target_y = self:get_furthest_targets()
  local is_inside_outer_x, is_inside_outer_y = self:is_outside_directions(
    self.furthest_target_x.box,
    self.furthest_target_y.box
  )
  local is_inside_inner_x, is_inside_inner_y = self:is_outside_directions(
    self.furthest_target_x.box,
    self.furthest_target_y.box,
    0.3
  )
  local animation_state = self:get_zoom_animation_state(
    is_inside_outer_x or is_inside_outer_y,
    is_inside_inner_x or is_inside_inner_y
  )

  if self.zoom_animation_coroutine == nil and not (animation_state == ZOOM_ANIMATION_STATE.NONE) then
    self.zoom_animation_coroutine = coroutine.create(function()
      self:animate_zoom(animation_state)
    end)
  end

  if not (self.zoom_animation_coroutine == nil) and coroutine.status(self.zoom_animation_coroutine) == "suspended" then
    coroutine.resume(self.zoom_animation_coroutine)
  end
end

function camera:zoom_game(zoom_value)
  self.zoom = self.zoom + zoom_value

  if self.zoom < ZOOM_MIN then
    self.zoom = ZOOM_MIN
  elseif self.zoom > ZOOM_MAX then
    self.zoom = ZOOM_MAX
  end

  self:set_canvas_game(self:get_screen_game_size())
end

-- Gets the following targets thats furthest on x and y axis
function camera:get_furthest_targets()
  local target_x, target_y = nil, nil

  for index = 1, table.get_size(self.follow_targets) do
    local target = self.follow_targets[index]
    local center_x, center_y = target.box:center()
    local distance_x, distance_y = math.abs(self.x - center_x), math.abs(self.y - center_y)

    if (target_x == nil or distance_x > math.abs(target_x.box:center_x())) then
      target_x = target
    end

    if (target_y == nil or distance_y > math.abs(target_y.box:center_y())) then
      target_y = target
    end
  end

  return target_x, target_y
end

function camera:set_camera_position(dt)
  self.delta_time = dt
  local number_of_targets = table.get_size(self.follow_targets)
  local position_x, position_y = 0, 0

  for index = 1, number_of_targets do
    local target = self.follow_targets[index]
    local center_x, center_y = target.box:center()

    position_x = position_x + center_x
    position_y = position_y + center_y
  end

  position_x = position_x / number_of_targets
  position_y = position_y / number_of_targets

  self:try_zoom()
  self:look_at(position_x, position_y)
end

function camera:animate_zoom(animation_state)
  local zoom_step = ZOOM_ANIMATION_STEP
  local zoom_speed = ZOOM_ANIMATION_SPEED / camera:get_screen_game_hud_diff()

  while zoom_step > 0 do
    zoom_step = zoom_step - zoom_speed
    self:zoom_game(animation_state == ZOOM_ANIMATION_STATE.OUT and -zoom_speed or zoom_speed)
    coroutine.yield()
  end

  self.zoom_animation_coroutine = nil
end

function camera:load()
  --self:toggle_fullscreen()
  local width, height = camera:get_screen_game_size()

  self:set_canvas_game(width, height)
  self:set_canvas_hud(width, height)
end

function camera:update(dt)
  if #self.follow_targets > 0 then
    self:set_camera_position(dt)
  end
end

return camera

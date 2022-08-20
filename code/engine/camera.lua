--[[
  PIXEL COORDINATES = love.mouse.getPosition() returns pixel coordinates
  top-left = (0, 0), bottom-right = screen resolution, e.g. 1920x1080 or 3440x1440 and so on.

  VIRTUAL RESOLUTION = Screen resolution / Scale. e.g. 1920x1080 / 6 = 320x180.
  We're dealing with small images, and scaling the canvas up to make the images look larger than it actually is.

  WORLD COORDINATES = Is the position of a entity or thing in the game world.
  SCREEN COORDINATES = Pixel coordinates on the screen that is upscaled same as the images.
]]

MIN_ZOOM = -3
MAX_ZOOM = 0
ZOOM_ANIMATION_STATE = {
  NONE = 0,
  IN = 1,
  OUT = 2,
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
  zoom = 0,
  zoom_animation_coroutine = nil,
  zoom_animation_initial_state = ZOOM_ANIMATION_STATE.NONE,
  zoom_animation_current_state = ZOOM_ANIMATION_STATE.NONE,
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

-- Adds target to follow
function camera:follow(target) table.insert(self.follow_targets, target) end

-- Removes target to follow
function camera:unfollow(target)
  local index = table.index_of(self.follow_targets, target)

  if not index == nil then
    table.remove(self.follow_targets, index)
  end
end

-- Returns camera position
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
function camera:is_outside_directions(world_x, world_y, border_margin_percentage)
  border_margin_percentage = border_margin_percentage or 0
  local half_width, half_height = camera:get_screen_game_half_size()
  half_width, half_height = half_width - (half_width * border_margin_percentage),
      half_height - (half_height * border_margin_percentage)

  local is_outside_x = world_x < self.x - half_width or world_x > self.x + half_width
  local is_outside_y = world_y < self.y - half_height or world_y > self.y + half_height

  return is_outside_x, is_outside_y
end

-- Returns true if its outside in any direction
function camera:is_outside(world_x, world_y, border_margin_percentage)
  local is_outside_x, is_outside_y = self:is_outside_directions(world_x, world_y, border_margin_percentage)

  return is_outside_x or is_outside_y
end

-- Preparing to draw the game world
function camera:start_draw_world()
  love.graphics.setCanvas(camera.canvas_game)
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
  love.graphics.draw(camera.canvas_game, 0, 0, 0, camera.scale + camera.zoom) -- Draw canvas upscaled
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
  self.canvas_game = love.graphics.newCanvas(width, height)
  self.canvas_game:setFilter("nearest", "nearest")
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

  if self.zoom < MIN_ZOOM then
    self.zoom = MIN_ZOOM
  elseif self.zoom > MAX_ZOOM then
    self.zoom = MAX_ZOOM
  end

  self:set_canvas_game(self:get_screen_game_size())
end

function camera:set_camera_position(dt)
  self.delta_time = dt
  local number_of_targets = table.get_size(self.follow_targets)
  local uttermost_x, uttermost_y = 0, 0
  local position_x, position_y = 0, 0
  local is_inside_outer, is_inside_outer_x, is_inside_outer_y = false, false, false
  local is_inside_inner, is_inside_inner_x, is_inside_inner_y = false, false, false

  for index = 1, number_of_targets do
    local target = self.follow_targets[index]
    local distance_x, distance_y = math.abs(self.x - target.center_position.x),
        math.abs(self.y - target.center_position.y)

    uttermost_x = distance_x > math.abs(uttermost_x) and target.center_position.x or uttermost_x
    uttermost_y = distance_y > math.abs(uttermost_y) and target.center_position.y or uttermost_y
    position_x = position_x + target.center_position.x
    position_y = position_y + target.center_position.y
  end

  position_x = position_x / number_of_targets
  position_y = position_y / number_of_targets

  is_inside_outer_x, is_inside_outer_y = self:is_outside_directions(uttermost_x, uttermost_y, 0.08)
  is_inside_inner_x, is_inside_inner_y = self:is_outside_directions(uttermost_x, uttermost_y, 0.25)
  is_inside_outer = is_inside_outer_x or is_inside_outer_y
  is_inside_inner = is_inside_inner_x or is_inside_inner_y

  self.zoom_animation_current_state = ZOOM_ANIMATION_STATE.NONE

  if self.zoom >= MIN_ZOOM and is_inside_outer then
    self.zoom_animation_current_state = ZOOM_ANIMATION_STATE.OUT
  elseif self.zoom < MAX_ZOOM and not is_inside_inner then
    self.zoom_animation_current_state = ZOOM_ANIMATION_STATE.IN
  end

  if self.zoom_animation_coroutine == nil and not (self.zoom_animation_current_state == ZOOM_ANIMATION_STATE.NONE) then
    self.zoom_animation_initial_state = self.zoom_animation_current_state
    self.zoom_animation_coroutine = coroutine.create(function() self:animate_zoom() end)
  end

  if not (self.zoom_animation_coroutine == nil) and coroutine.status(self.zoom_animation_coroutine) == "suspended" then
    coroutine.resume(self.zoom_animation_coroutine, dt)
  end

  self:look_at(position_x, position_y)
end

function camera:animate_zoom()
  local zoom_amount = 0.5

  while zoom_amount > 0 do
    local zoom_speed = 0.0125
    zoom_amount = zoom_amount - zoom_speed
    self:zoom_game(self.zoom_animation_initial_state == ZOOM_ANIMATION_STATE.OUT and -zoom_speed or zoom_speed)
    coroutine.yield()
  end

  self.zoom_animation_coroutine = nil
  self.zoom_animation_initial_state = ZOOM_ANIMATION_STATE.NONE
end

function camera:load()
  --self:toggle_fullscreen()

  if self.is_fullscreen then
    self:set_canvas()
  end

  self:set_canvas()
end

function camera:update(dt)
  if #self.follow_targets > 0 then
    self:set_camera_position(dt)
  end
end

return camera

local rectangle = require("code.engine.rectangle")
local game_event_manager = require("code.engine.game_event.game_event_manager")
local camera = require("code.engine.camera")
local projectile = {}

local projectile_data = {}
projectile_data[GAME.PROJECTILE_TYPES.ARROW] = { speed = 100, bounds = { 7, 21 }, quad_data = { 308, 186, 7, 21 } }
projectile_data[GAME.PROJECTILE_TYPES.BULLET] = { speed = 130, bounds = { 16, 16 }, quad_data = { 288, 320, 16, 16 } }
projectile_data[GAME.PROJECTILE_TYPES.MAGIC] = { speed = 70, bounds = { 16, 16 }, quad_data = { 288, 240, 16, 16 } }

local grid = nil


function projectile:shoot(start_position, direction, ignore_targets_set)
  self.center_position = start_position
  self.ignore_targets = ignore_targets_set
  set.add(self.ignore_targets, self.client.guid)
  self.move_dir = direction
  self.angle = math.atan2(direction.y, direction.x) + math.rad(90)
end

function projectile:check_collisions()
  local clients = grid:find_near({ x = self.center_position.x, y = self.center_position.y }, { w = 32, h = 32 },
    self.ignore_targets)
  self.nearby_clients = table.get_size(clients)

  local overlapping = false
  for key, value in pairs(clients) do
    local x, y, w, h = key.position.x, key.position.y, key.dimensions.w, key.dimensions.h

    x = x - w / 2
    y = y - w / 2

    if self.box:overlap(x, y, w, h) then
      self:deactivate()
      return
    end
  end
end

function projectile:update(dt)
  local x, y = self.center_position.x, self.center_position.y
  x = x + self.move_dir.x * self.speed * dt
  y = y + self.move_dir.y * self.speed * dt
  self.center_position.x = x
  self.center_position.y = y

  if (self.center_position.x > camera.visual_resolution_x or self.center_position.x < 0) then
    self:deactivate()
    return
  end

  if (self.center_position.y > camera.visual_resolution_y or self.center_position.y < 0) then
    self:deactivate()
    return
  end

  self.box.x = self.center_position.x - self.box.w / 2
  self.box.y = self.center_position.y - self.box.h / 2

  self.client.position = self.center_position
  grid:update(self.client)
  self:check_collisions()
end

function projectile:draw()
  local _, _, w, h = self.quad:getViewport()
  local origin_x, origin_y = w / 2, h / 2

  love.graphics.draw(
    self.image,
    self.quad, self.center_position.x,
    self.center_position.y, self.angle, 1, 1, origin_x, origin_y
  )
end

function projectile:activate()
  self.active = true
  game_event_manager.invoke(ENTITY_EVENT_TYPES.ACTIVATED, self)
end

function projectile:deactivate()
  self.active = false
  grid:remove_client(self.client)
  table.insert(self.pool, self)
  game_event_manager.invoke(ENTITY_EVENT_TYPES.DEACTIVATED, self)
end

function projectile:create(sprite_sheet, entity_grid, type, pool)
  self.__index = self

  grid = entity_grid
  local center_position = { x = 0, y = 0 }
  local x, y, w, h = unpack(projectile_data[type].quad_data)
  local quad = love.graphics.newQuad(x, y, w, h, sprite_sheet:getDimensions())
  local client = grid:new_client(center_position, { w = 16, h = 16 }, "asdf")

  local obj = setmetatable({
    type = type,
    pool = pool,
    ignore_targets = {},
    client = client,
    angle = math.rad(90),
    active = false,
    move_dir = { x = 1, y = 1 },
    speed = projectile_data[type].speed,
    quad = quad,
    box = rectangle:create(-w / 2, -h / 2, projectile_data[type].bounds[1], projectile_data[type].bounds[2]),
    center_position = center_position,
    image = sprite_sheet
  }, self)

  return obj
end

return projectile

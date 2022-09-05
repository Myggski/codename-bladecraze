local rectangle = require "code.engine.rectangle"
local game_event_manager = require "code.engine.game_event.game_event_manager"
local world_grid = require "code.engine.world_grid"
local camera = require "code.engine.camera"

local projectile = {}
local projectile_data = {}
local grid = nil

projectile_data[GAME.PROJECTILE_TYPES.ARROW] = { speed = 7, bounds = { 7 / 16, 21 / 16 }, quad_data = { 308, 186, 7, 21 } }
projectile_data[GAME.PROJECTILE_TYPES.BULLET] = { speed = 8, bounds = { 1, 1 }, quad_data = { 288, 320, 16, 16 } }
projectile_data[GAME.PROJECTILE_TYPES.MAGIC] = { speed = 6, bounds = { 1, 1 }, quad_data = { 288, 240, 16, 16 } }

function projectile:shoot(start_position, direction, ignore_targets_set)
  self.box.x = start_position.x - self.box.w / 2
  self.box.y = start_position.y - self.box.h / 2
  self.ignore_targets = ignore_targets_set
  set.add(self.ignore_targets, self.client.guid)
  self.move_dir = direction
  self.angle = math.atan2(direction.y, direction.x) + math.rad(90)
end

function projectile:check_collisions()
  local clients = grid:find_near(
    { x = self.box:center_x(), y = self.box:center_y() },
    { w = 2, h = 2 },
    self.ignore_targets
  )
  self.nearby_clients = table.get_size(clients)

  for key, _ in pairs(clients) do
    local x, y, w, h = key.position.x, key.position.y, key.dimensions.w, key.dimensions.h

    x = x - w / 2
    y = y - h / 2

    if self.box:overlap(x, y, w, h) then
      self:deactivate()
      return
    end
  end
end

function projectile:update(dt)
  local x, y = self.box:center()
  x = x + self.move_dir.x * self.speed * dt
  y = y + self.move_dir.y * self.speed * dt

  self.box.x = x - self.box.w / 2
  self.box.y = y - self.box.h / 2
  self.client.position = { x = self.box:center_x(), y = self.box:center_y() }

  grid:update(self.client)
  self:check_collisions()

  if camera:is_outside_camera_view(self.box) then
    self:deactivate()
  end
end

function projectile:draw()
  local _, _, w, h = self.quad:getViewport()
  local origin_x, origin_y = w / 2, h / 2

  love.graphics.draw(
    self.image,
    self.quad,
    world_grid:convert_to_world(self.box:center_x()),
    world_grid:convert_to_world(self.box:center_y()),
    self.angle,
    1,
    1,
    origin_x,
    origin_y
  )
end

function projectile:activate()
  self.active = true
  if self.client == nil then
    self.client = grid:new_client({ x = self.box:center_x(), y = self.box:center_y() }, { w = 1, h = 1 }, "asdf")
  end
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
  local center_position = { x = -9999, y = -9999 }
  local x, y, w, h = unpack(projectile_data[type].quad_data)
  local quad = love.graphics.newQuad(x, y, w, h, sprite_sheet:getDimensions())
  --local client = grid:new_client(center_position, { w = 1, h = 1 }, "asdf")

  local obj = setmetatable({
    type = type,
    pool = pool,
    ignore_targets = {},
    client = nil,
    angle = math.rad(90),
    active = false,
    move_dir = { x = 1, y = 1 },
    speed = projectile_data[type].speed,
    quad = quad,
    box = rectangle:create(center_position.x - (w / 2), center_position.y - (h / 2), projectile_data[type].bounds[1],
      projectile_data[type].bounds[2]),
    image = sprite_sheet
  }, self)

  return obj
end

return projectile

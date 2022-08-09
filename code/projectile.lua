local rectangle = require("code.engine.rectangle")
local game_event_manager = require("code.engine.game_event.game_event_manager")
local camera = require("code.engine.camera")

local projectile = {}
local projectile_pool = {}

local projectile_data = {}
projectile_data[PROJECTILE_TYPES.ARROW] = { speed = 100, bounds = { 7, 21 }, quad_data = { 308, 186, 7, 21 } }
projectile_data[PROJECTILE_TYPES.BULLET] = { speed = 130, bounds = { 16, 16 }, quad_data = { 288, 320, 16, 16 } }
projectile_data[PROJECTILE_TYPES.MAGIC] = { speed = 70, bounds = { 16, 16 }, quad_data = { 288, 240, 16, 16 } }


local sprite_sheet = nil

local grid = nil

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
  --self.color = overlapping and { 1, 0, 0, 1 } or { 1, 1, 1, 1 }
end

function projectile:set_ignore_targets(ignore_targets)
  self.ignore_targets = ignore_targets
  set.add(self.ignore_targets, self.client.guid)
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
  game_event_manager:invoke(ENTITY_EVENT_TYPES.ACTIVATED, self)
end

function projectile:deactivate()
  self.active = false
  grid:remove_client(self.client)
  local prevCount = #self.pool
  table.insert(self.pool, self)
  print(prevCount, #self.pool)
  game_event_manager:invoke(ENTITY_EVENT_TYPES.DEACTIVATED, self)
end

function projectile:create(type, pool)
  self.__index = self
  local center_position = { x = 0, y = 0 }
  local x, y, w, h = unpack(projectile_data[type].quad_data)
  local quad = love.graphics.newQuad(x, y, w, h, sprite_sheet:getDimensions())
  local client = grid:new_client(center_position, {w=16, h=16}, "asdf")
  local obj = setmetatable({
    type = type,
    pool = pool,
    ignore_targets = {},
    client = client,
    angle = 1.5708,
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

function projectile:get(type)
  if (projectile_pool[type] == nil) then
    print("could not get projectile: type not found")
    return
  end
  -- local current = projectile_pool[type].current_index
  -- local count = projectile_pool[type].count
  -- if (current > count) then
  --   current = 1
  -- end
  --local instance = projectile_pool[type].list[current]
  local count = #projectile_pool[type].list
  if count == 0 then
    return nil
  end
  local instance = table.remove(projectile_pool[type].list, count)
  instance:activate()
  --current = current + 1
  --projectile_pool[type].current_index = current
  return instance
end

function projectile:create_pool(image, type, count, entity_grid)
  grid = entity_grid
  if sprite_sheet == nil then
    sprite_sheet = image
  end
  if projectile_pool[type] == nil then
    projectile_pool[type] = {current_index = 1, count = count, list = {}}
    for i = 1, count do
      print(projectile_pool[type])
      table.insert(projectile_pool[type].list, projectile:create(type, projectile_pool[type].list))
    end
  end
end

return {projectile = projectile, projectile_pool = projectile_pool}

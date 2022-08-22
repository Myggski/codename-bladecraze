local player_input = require "code.player.player_input"
local rectangle = require "code.engine.rectangle"
local animations = require "code.engine.animations"
local player_drawing = require "code.player.player_drawing"
local character_data = require "code.player.character_data"
local camera = require "code.engine.camera"
local asset_manager = require "code.engine.asset_manager"
local projectile_pool = require "code.projectiles.projectile_pool"

local player = {}
local grid = nil

function player:check_collisions(desired_location)
  local projectile_guid = "projectile" .. self.guid
  local box = table.deepcopy(self.box)
  local clients = grid:find_near({ x = desired_location.x, y = desired_location.y }, { w = 32, h = 32 },
    set.create { self.guid, projectile_guid })

  if not box then
    return
  end

  self.nearby_clients = table.get_size(clients)
  box.x = desired_location.x - box.w / 2
  box.y = desired_location.y - box.h / 2

  local overlapping = false
  for key, _ in pairs(clients) do
    local x, y, w, h = key.position.x, key.position.y, key.dimensions.w, key.dimensions.h

    x = math.floor(x - w / 2)
    y = math.floor(y - w / 2)
    if box:overlap(x, y, w, h) then
      overlapping = true
    end
  end
  return overlapping
end

function player:handle_action(action)
  self.action_table[action](self)
end

function player:handle_shoot()
  if self.shoot_timer <= 0 then
    local instance = projectile_pool:get_projectile(self.projectile_type)
    if instance then

      --[[
        future: 
        add cleaner way to prevent arrows from colliding
        with player or themselves
      ]]
      local center_x, center_y = self.box:center()
      local number = love.math.random(8, 10)
      self.arrow_sound:setPitch(number / 10)
      self.arrow_sound:play()
      instance.client.guid = "projectile" .. self.guid
      local start_pos = {
        x = center_x + self.input.aim_dir.x * 16,
        y = center_y + self.input.aim_dir.y * 16
      }
      local ignore_targets = set.create({ self.guid })
      instance:shoot(start_pos, self.input.aim_dir, ignore_targets)
      self.shoot_timer = self.shoot_cd
    end
  end
end

function player:get_moving_direction()
  local x, y = self.box:center_x() - self.previous_position.x, self.box:center_y() - self.previous_position.y
  return math.normalize(x, y)
end

function player:handle_melee()
  print("melee action")
end

function player:handle_special()
  print("special action")
end

function player:handle_ultimate()
  print("ultimate action")
end

function player:update(dt)
  local center_position = { x = self.box:center_x(), y = self.box:center_y() }
  self.input = player_input.get_input(self.index, center_position)

  local new_position = {
    x = center_position.x + self.input.move_dir.x * 100 * dt,
    y = center_position.y + self.input.move_dir.y * 100 * dt,
  }
  local new_rectangle = rectangle:create(
    new_position.x - (self.box.w / 2),
    new_position.y - (self.box.h / 2),
    self.box.w,
    self.box.h
  )

  local collided = self:check_collisions(new_position)
  local is_outside = camera:is_outside_camera_view(new_rectangle)

  --Move player if no collisions
  if not collided and not is_outside then
    self.previous_position = { x = center_position.x, y = center_position.y }
    self.client.position = new_position
    self.box.x = new_position.x - self.box.w / 2
    self.box.y = new_position.y - self.box.h / 2
    grid:update(self.client)
  end

  if not (self.input.aim_dir.x == 0) then
    self.direction = self.input.aim_dir.x > 0 and 1 or -1
  end

  if not (self.input.action == PLAYER.ACTIONS.NONE) then
    self:handle_action(self.input.action)
  end

  --Change between idle and run animations
  local animation = self.animations.current
  if self.input.move_dir.x == 0 and self.input.move_dir.y == 0 then
    animation = self.animations.idle
  else
    animation = self.animations.run
  end

  self.shoot_timer = self.shoot_timer - dt
  player_drawing.update_animation(animation, dt)
  self.animations.current = animation
end

function player:draw()
  love.graphics.setColor(self.color)
  player_drawing.draw_player(self)
  player_drawing.draw_stats(self)
end

function player:create(data)
  self.__index = self

  local arrow_sound = asset_manager:get_audio(
    "arrow.wav",
    "static",
    character_data[data.class].name
  )
  local idle_animation = animations.new_animation(
    data.image,
    character_data[data.class].idle_animation,
    1
  )
  local run_animation = animations.new_animation(
    data.image,
    character_data[data.class].run_animation,
    0.5
  )
  local hit_animation = animations.new_animation(
    data.image,
    character_data[data.class].hit_animation,
    2
  )

  --every player should be on the same grid
  if grid == nil then
    grid = data.grid
  end

  local animations = {
    current = idle_animation,
    idle = idle_animation,
    run = run_animation,
    hit = hit_animation
  }

  local x, y = unpack(data.position)
  local w, h = unpack(data.bounds)

  local guid = character_data[data.class].name
  local center_position = { x = x, y = y }
  local client = grid:new_client(
    { x = center_position.x, y = center_position.y },
    { w = 16, h = 16 },
    guid
  )
  local projectile_type = character_data[data.class].projectile_type
  local action_table = {
    projectile_type == nil and self.handle_melee or self.handle_shoot,
    self.handle_special,
    self.handle_ultimate
  }
  local obj = {
    action_table = action_table,
    projectile_type = projectile_type,
    index = data.index,
    animations = animations,
    stats = character_data[data.class].stats,
    box = rectangle:create(x - w / 2, y - h / 2, w, h),
    class = data.class,
    name = character_data[data.class].name,
    client = client,
    previous_position = { x = 0, y = 0 },
    guid = guid,
    arrow_sound = arrow_sound,
    active = true,
    shoot_cd = 0.5,
    shoot_timer = 0,
    nearby_clients = 0,
    direction = 1,
    color = { 1, 1, 1, 1 },
    input = {},
  }

  setmetatable(obj, self)

  return obj
end

return player

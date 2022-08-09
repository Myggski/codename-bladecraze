local player_input = require("code.player.player_input")
local rectangle = require("code.engine.rectangle")
local animations = require("code.engine.animations")
local player_drawing = require("code.player.player_drawing")
local character_data = require("code.player.character_data")
local game_event_manager = require("code.engine.game_event.game_event_manager")

local projectile_manager = require("code.projectile")


local player = {}
local grid = nil

function player:update(dt)
  self.input = player_input.get_input(self.index, self.center_position)
  --Move player
  self.center_position.x = self.center_position.x + self.input.move_dir.x
  self.center_position.y = self.center_position.y + self.input.move_dir.y

  self.box.x = self.center_position.x - self.box.w / 2
  self.box.y = self.center_position.y - self.box.h / 2

  self.client.position = self.center_position

  grid:update(self.client)
  self:check_collisions()

  if self.input.aim_dir.x ~= 0 then
    self.direction = self.input.aim_dir.x > 0 and 1 or -1
  end

  if self.input.shoot then
    if self.projectile_type ~= nil then
      if (self.shoot_timer <= 0) then
        local projectile = projectile_manager.projectile:get(self.projectile_type)
        if projectile ~= nil then
          projectile.center_position.x = self.center_position.x + self.input.aim_dir.x * 16
          projectile.center_position.y = self.center_position.y + self.input.aim_dir.y * 16
          
          local ignore_targets = set.create({self.guid})
          projectile.client.guid = "projectile"..self.guid
          projectile:set_ignore_targets(ignore_targets)
          projectile.move_dir = self.input.aim_dir
          projectile.angle = math.atan2(self.input.aim_dir.y, self.input.aim_dir.x) + 1.5708
          self.shoot_timer = self.shoot_cd
        end
      end
    end
  end

  --Change between idle and run animations
  local animation = self.animations.current
  if (self.input.x == 0 and self.input.y == 0) then
    animation = self.animations.idle
  else
    animation = self.animations.run
  end
  
  self.shoot_timer = self.shoot_timer - dt
  player_drawing.update_animation(animation, dt)
  self.animations.current = animation
end

function player:check_collisions()
  local projectile_guid = "projectile"..self.guid
  local clients = grid:find_near({ x = self.center_position.x, y = self.center_position.y }, { w = 32, h = 32 },
  set.create{self.guid, projectile_guid})

  self.nearby_clients = table.get_size(clients)

  local overlapping = false
  for key, value in pairs(clients) do
    local x, y, w, h = key.position.x, key.position.y, key.dimensions.w, key.dimensions.h

    x = x - w / 2
    y = y - w / 2

    if self.box:overlap(x, y, w, h) then
      overlapping = true
    end
  end
  self.color = overlapping and { 1, 0, 0, 1 } or { 1, 1, 1, 1 }
end

function player:draw()
  love.graphics.setColor(self.color)
  player_drawing.draw_player(self)
  player_drawing.draw_player_bounding_box(self)
  local str = ""
  for key, value in pairs(self.stats) do
    str = str .. key .. ":" .. value .. "\n"
  end
  --player_drawing.draw_text(self.box.x, self.box.y, self.nearby_clients)
  player_drawing.draw_text(self.box.x, self.box.y+20, str)
end

function player:create(data)
  self.__index = self

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

  grid = data.grid

  local animations = { current = idle_animation, idle = idle_animation, run = run_animation, hit = hit_animation }
  
  local x, y = unpack(data.position)
  local w, h = unpack(data.bounds)

  local guid = character_data[data.class].name
  local center_position = { x = x, y = y }
  local client = grid:new_client({ x = center_position.x, y = center_position.y }, { w = 16, h = 16 }, guid)

  local obj = {
    projectile_type = character_data[data.class].projectile_type,
    index = data.index,
    animations = animations,
    stats = character_data[data.class].stats,
    box = rectangle:create(x - w / 2, y - h / 2, w, h),
    class = data.class,
    name = character_data[data.class].name,
    client = client,
    center_position = center_position,
    guid = guid,
    active = true,
    shoot_cd = 0.1,
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

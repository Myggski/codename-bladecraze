local player_input = require("code.player.player_input")
local rectangle = require("code.engine.rectangle")
local animations = require("code.engine.animations")
local player_drawing = require("code.player.player_drawing")
local character_data = require("code.player.character_data")

local player = {}

function player:update(dt)
  self.input = player_input:get_input(self.index)

  --Change between idle and run animations
  if (self.input.x == 0 and self.input.y == 0) then
    self.current_animation = self.idle_animation
  else
    self.current_animation = self.run_animation
  end

  --Update animation
  self.current_animation.current_time = self.current_animation.current_time + dt
  if self.current_animation.current_time > self.current_animation.duration then
    self.current_animation.current_time = self.current_animation.current_time - self.current_animation.duration
  end

  --Move player
  self.box.x = self.box.x + self.input.x
  self.box.y = self.box.y + self.input.y
end

function player:draw()
  player_drawing.draw_player(self)
  player_drawing.draw_player_bounding_box(self)
  player_drawing.draw_name(self.box.x, self.box.y, self.name)
end

function player:create(data)
  self.__index = self

  local idle_animation = animations.new_animation(
    data.image,
    character_data[data.character].idle_animation,
    1
  )
  local run_animation = animations.new_animation(
    data.image,
    character_data[data.character].run_animation,
    0.5
  )
  local hit_animation = animations.new_animation(
    data.image,
    character_data[data.character].hit_animation,
    2
  )

  local x, y = unpack(data.position)
  local w, h = unpack(data.bounds)

  local obj = setmetatable({
    index = data.index,
    idle_animation = idle_animation,
    run_animation = run_animation,
    hit_animation = hit_animation,
    current_animation = idle_animation,
    box = rectangle:create(x, y, w, h),
    character = data.character,
    name = character_data[data.character].name,
    color = { 1, 1, 1, 1 },
    input = {},
  }, self)

  return obj
end

return player

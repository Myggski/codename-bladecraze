Player = {}
require("code.player.player_input")
local rectangle = require("code.engine.rectangle")
local animations = require("code.engine.animations")
local player_drawing = require("code.player.player_drawing")
local player_data = require("code.player.player_data")

function Player:update(dt)
  self.input = player_input:get_input(self.index)

  --change between idle and run animations
  if (self.input.x ~= 0 or self.input.y ~= 0) then
    self.current_animation = self.run_animation
  else
    self.current_animation = self.idle_animation
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

function Player:create(data)
  self.__index = self

  local idle_animation = animations.new_animation(
    data.image,
    player_data[data.index].idle_animation,
    1
  )
  local run_animation = animations.new_animation(
    data.image,
    player_data[data.index].run_animation,
    0.5
  )
  local hit_animation = animations.new_animation(
    data.image,
    player_data[data.index].hit_animation,
    2
  )

  local obj = setmetatable({
      index = data.index,
      idle_animation = idle_animation,
      run_animation = run_animation,
      hit_animation = hit_animation,
      current_animation = idle_animation,
      box = rectangle:create2(data.position, data.bounds), --x, y, w ,h 
      color = {1,1,1,1},
      input = {},
  }, self)

  return obj
end

return Player

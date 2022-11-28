local bubble_controller = require "code.game.entities.bubble_controller"
local player = require "code.game.entities.player"
local helper = require "code.game.systems.bubble_controller_system_helper"
local player_input = require "code.game.player_input"
local system = require "code.engine.ecs.system"

-- Is being called every frame
local bubble_controller_system = system(function(self, dt)
  local entities = helper.sort_entities(self:to_list(bubble_controller.get_archetype()))
  local number_available_joysticks = #player_input.get_available_joysticks()
  local number_active_controllers = #player_input.get_active_controllers()
  local expected_number_of_bubbles = number_available_joysticks + 1 - number_active_controllers

  -- Remove all bubbles if max players is reached
  if #self:to_list(player.get_archetype()) >= GAME.MAX_PLAYERS then
    if #entities > 0 then
      helper.destroy_all(entities)
    end

    return
  end

  -- If there are less bubbles than expected, in that case add bubbles
  -- Elseif there are more bubbles than expected, in that case remove bubbles
  if #entities < expected_number_of_bubbles then
    helper.create_bubbles(self:get_world(), entities, number_available_joysticks, expected_number_of_bubbles)
  elseif #entities > expected_number_of_bubbles then
    helper.destroy_bubbles(self:get_world(), entities, expected_number_of_bubbles, true)
  end
end)

-- On System Start
function bubble_controller_system:on_start() helper.enable_controller_events(self) end

-- On System Destroy
function bubble_controller_system:on_destroy() helper.disable_controller_events(self) end

return bubble_controller_system

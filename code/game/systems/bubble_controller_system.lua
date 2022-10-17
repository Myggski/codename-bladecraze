local system = require "code.engine.ecs.system"
local entity_query = require "code.engine.ecs.entity_query"
local helper = require "code.game.systems.bubble_controller_system_helper"
local player_input = require "code.player.player_input"

local bubble_controller_query = entity_query:all(
  components.animation,
  components.player_data,
  components.position,
  components.size,
  components.target_position
).none(components.input)

-- The system that's being called every frame
local bubble_controller_system = system(bubble_controller_query, function(self, _)
  local entities = helper.sort_entities(self:for_each())
  local number_available_joysticks = #player_input.get_available_joysticks()
  local number_active_controllers = #player_input.get_active_controllers()
  local expected_number_of_bubbles = number_available_joysticks + 1 - number_active_controllers

  -- Remove all bubbles if max players is reached
  if number_active_controllers >= GAME.MAX_PLAYERS then
    helper.destroy_all(entities)
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

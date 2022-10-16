local system = require "code.engine.ecs.system"
local game_event_manager = require "code.engine.game_event.game_event_manager"
local entity_query = require "code.engine.ecs.entity_query"
local player_input = require "code.player.player_input"
local bubble_controller = require "code.game.entities.bubble_controller"
local player = require "code.game.entities.player"

local bubble_controller_query = entity_query:all(
  components.animation,
  components.player_data,
  components.position,
  components.size,
  components.target_position
).none(components.input)

local center_bubble_position = { x = -1, y = -1.5 }

local function sort_on_player_id(a, b)
  return a[components.player_data].player_id < b[components.player_data].player_id
end

local function get_bubble_position(bubble_index, number_of_bubbles)
  local offset_x = (2 * bubble_index - 1) - (1 * number_of_bubbles)
  return { x = center_bubble_position.x + offset_x, y = center_bubble_position.y }
end

local function get_available_ids(entities)
  local possible_ids, remove_index = player_input.get_non_active_ids(), -1

  for index = 1, #entities do
    remove_index = table.index_of(possible_ids, entities[index][components.player_data].player_id)

    if remove_index > 0 then
      table.remove(possible_ids, remove_index)
    end
  end

  if #possible_ids > 0 then
    return possible_ids
  end

  return {}
end

local function get_bubble_id(entities)
  local ids = get_available_ids(entities)

  if #ids > 0 then
    return ids[1]
  end

  return -1
end

local function search_keyboard_bubble(entities)
  local keyboard_bubble, entity, player_data = nil, nil, nil

  -- Looking for keyboard bubble
  for entity_index = 1, #entities do
    entity = entities[entity_index]
    player_data = entity[components.player_data]

    if player_input.is_keyboard(player_data.controller_type) then
      keyboard_bubble = entities[entity_index]
    end
  end

  return keyboard_bubble
end

local function add_bubbles(world, entities, number_available_joysticks, expected_number_of_bubbles)
  local keyboard_bubble, new_bubble_id = search_keyboard_bubble(entities), -1

  while #entities < expected_number_of_bubbles do
    new_bubble_id = get_bubble_id(entities)

    if not keyboard_bubble and not player_input.is_keyboard_active() then
      keyboard_bubble = bubble_controller(
        world,
        new_bubble_id,
        CONTROLLER_TYPES.KEYBOARD,
        get_bubble_position(new_bubble_id, number_available_joysticks + 1)
      )
      table.insert(entities, new_bubble_id, keyboard_bubble)
    else
      table.insert(entities,
        new_bubble_id,
        bubble_controller(
          world,
          new_bubble_id,
          CONTROLLER_TYPES.GAMEPAD,
          get_bubble_position(new_bubble_id, number_available_joysticks + 1)
        )
      )
    end
  end
end

local function destroy_bubbles(world, entities, expected_number_of_bubbles, add_player)
  local active_controllers = player_input.get_active_controllers()
  local entity, next_entity, player_data, active_controller = nil, nil, nil, nil

  while #entities > expected_number_of_bubbles do
    for entity_index = 1, #entities do
      entity, next_entity = entities[entity_index], entities[entity_index + 1]
      player_data = entity[components.player_data]

      for controller_index = 1, #active_controllers do
        active_controller = active_controllers[controller_index]

        if player_data.player_id == active_controller.player_id then
          if add_player then
            active_controller.connected_player = player(world, player_data.player_id, entity[components.position])
          end

          -- Moves the keyboard bubble
          if player_input.is_keyboard(player_data.controller_type) and not player_input.is_keyboard_active() then
            next_entity[components.animation][ANIMATION_STATE_TYPES.IDLE] = entity[components.animation][
                ANIMATION_STATE_TYPES.IDLE]
            next_entity[components.player_data].controller_type = CONTROLLER_TYPES.KEYBOARD
            entity[components.player_data].controller_type = CONTROLLER_TYPES.GAMEPAD
          elseif player_input.is_gamepad(player_data.controller_type) and player_input.is_keyboard_active() then
            local keyboard_bubble = search_keyboard_bubble(entities)

            if keyboard_bubble then
              keyboard_bubble[components.animation][ANIMATION_STATE_TYPES.IDLE] = entity[components.animation][
                  ANIMATION_STATE_TYPES.IDLE]
              keyboard_bubble[components.player_data].controller_type = CONTROLLER_TYPES.GAMEPAD
              entity[components.player_data].controller_type = CONTROLLER_TYPES.KEYBOARD
            end
          end

          table.remove(entities, entity_index)
          entity:destroy()
          return
        end
      end
    end

    -- Cleanup when a controller gets disconnected
    if #entities > expected_number_of_bubbles then
      table.remove(entities, #entities)
      entities[#entities]:destroy()
    end
  end
end

local function update_bubble_positions(entities, number_available_joysticks)
  for index = 1, number_available_joysticks + 1 do
    if entities[index] then
      entities[index][components.target_position] = get_bubble_position(
        entities[index][components.player_data].player_id,
        number_available_joysticks + 1
      )
    end
  end
end

local bubble_controller_system = system(bubble_controller_query, function(self, _)
  local entities = self:to_list()
  local number_available_joysticks = #player_input.get_available_joysticks()
  local number_active_controllers = #player_input.get_active_controllers()
  local expected_number_of_bubbles = number_available_joysticks + 1 - number_active_controllers
  table.sort(entities, sort_on_player_id)

  if number_active_controllers >= GAME.MAX_PLAYERS then
    destroy_bubbles(self:get_world(), entities, 0, false)
    return
  end

  -- If there are less bubbles than expected, in that case add bubbles
  -- Elseif there are more bubbles than expected, in that case remove bubbles
  if #entities < expected_number_of_bubbles then
    add_bubbles(self:get_world(), entities, number_available_joysticks, expected_number_of_bubbles)

    update_bubble_positions(entities, number_available_joysticks)
  elseif #entities > expected_number_of_bubbles then
    destroy_bubbles(self:get_world(), entities, expected_number_of_bubbles, true)

    update_bubble_positions(entities, number_available_joysticks)
  end
end)

local function disable_events(self)
  if self.player_key_pressed_event then
    game_event_manager.remove_listener(GAME_EVENT_TYPES.KEY_PRESSED, self.player_key_pressed_event)
    self.player_key_pressed_event = nil
  end

  if self.player_joystick_pressed_event then
    game_event_manager.remove_listener(GAME_EVENT_TYPES.JOYSTICK_PRESSED, self.player_joystick_pressed_event)
    self.player_joystick_pressed_event = nil
  end
end

local function toggle_player_activation(controller_type, joystick)
  if player_input.is_pressing_start(controller_type, joystick) then
    if player_input.is_controller_active(controller_type, joystick) then
      player_input.deactivate_controller(controller_type, joystick)
    else
      player_input.active_controller(controller_type, joystick)
    end
  end
end

local function enable_events(self)
  disable_events(self)

  self.player_key_pressed_event = function() toggle_player_activation(CONTROLLER_TYPES.KEYBOARD) end
  self.player_joystick_pressed_event = function(joystick) toggle_player_activation(CONTROLLER_TYPES.GAMEPAD, joystick)
  end

  game_event_manager.add_listener(GAME_EVENT_TYPES.KEY_PRESSED, self.player_key_pressed_event)
  game_event_manager.add_listener(GAME_EVENT_TYPES.JOYSTICK_PRESSED, self.player_joystick_pressed_event)
end

function bubble_controller_system:on_start() enable_events(self) end

function bubble_controller_system:on_destroy() disable_events(self) end

return bubble_controller_system

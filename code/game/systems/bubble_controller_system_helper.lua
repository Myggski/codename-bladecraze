local bubble_controller = require "code.game.entities.bubble_controller"
local components = require "code.engine.components"
local game_event_manager = require "code.engine.game_event.game_event_manager"
local player = require "code.game.entities.player"
local player_input = require "code.game.player_input"
local vector2 = require "code.engine.vector2"
local audio = require "code.engine.audio"

-- Sorting function for table.sort -> Sorts on player_id
local function sort_on_player_id(a, b)
  return a[components.player_data].player_id < b[components.player_data].player_id
end

-- Sort entities on player_id
local function sort_entities(entities)
  table.sort(entities, sort_on_player_id)

  return entities
end

-- Calcualtes and returns the bubble position depending on id and number of bubbles that are available
local function get_bubble_position(bubble_id, expected_number_of_bubbles)
  local center_bubble_position = vector2(-1, -1.5)
  local offset_x = (2 * bubble_id - 1) - (1 * expected_number_of_bubbles)

  center_bubble_position.x = center_bubble_position.x + offset_x

  return center_bubble_position
end

-- Returns a unique bubble id
-- TODO: Change this so it can show more than 4 bubbles
-- Example: You have 4 or more joysticks connected, all of them should be added for display
local function get_bubble_id(entities)
  local possible_ids, remove_index = player_input.get_non_active_ids(), -1

  for index = 1, #entities do
    remove_index = table.index_of(possible_ids, entities[index][components.player_data].player_id)

    if remove_index > 0 then
      table.remove(possible_ids, remove_index)
    end
  end

  return #possible_ids > 0 and possible_ids[1] or -1
end

-- Get bubbles depending on controller type
local function get_bubbles_of_type(entities, controller_type)
  local bubbles = {}

  for index = 1, #entities do
    if entities[index][components.player_data].controller_type == controller_type then
      table.insert(bubbles, entities[index])
    end
  end

  return bubbles
end

-- Gets the keyboard bubble
local function get_keyboard_bubble(entities)
  local bubbles = get_bubbles_of_type(entities, CONTROLLER_TYPES.KEYBOARD)

  return #bubbles > 0 and bubbles[1] or nil
end

-- Returns the index of the bubble
local function get_bubble_index(entities, player_id)
  for index = 1, #entities do
    if entities[index][components.player_data].player_id == player_id then
      return index
    end
  end

  return -1
end

-- Moves the bubbles if controllers are being added or removed
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

-- All the joysticks that are bubbles but are not available should be removed
local function remove_disconnected_joysticks(entities)
  local gamepad_bubbles = get_bubbles_of_type(entities, CONTROLLER_TYPES.GAMEPAD)
  local number_available_joysticks = #player_input.get_available_joysticks()
  local number_active_joysticks = #player_input.get_active_joysticks()
  local expected_number_of_gamepad_bubbles = number_available_joysticks - number_active_joysticks

  while #gamepad_bubbles > expected_number_of_gamepad_bubbles do
    table.remove(
      entities,
      get_bubble_index(entities, gamepad_bubbles[#gamepad_bubbles][components.player_data].player_id)
    )

    gamepad_bubbles[#gamepad_bubbles]:destroy()
    table.remove(gamepad_bubbles, #gamepad_bubbles)
  end

  update_bubble_positions(entities, number_available_joysticks)
end

-- Adds bubble entities
local function create_bubbles(world, entities, number_available_joysticks, expected_number_of_bubbles)
  local keyboard_bubble, new_bubble_id, controller_type = get_keyboard_bubble(entities), -1, CONTROLLER_TYPES.GAMEPAD

  -- Add bubbles until there's enough bubbles
  while #entities < expected_number_of_bubbles do
    keyboard_bubble = get_keyboard_bubble(entities)
    new_bubble_id = get_bubble_id(entities)
    controller_type = (keyboard_bubble or player_input.is_keyboard_active())
        and CONTROLLER_TYPES.GAMEPAD
        or CONTROLLER_TYPES.KEYBOARD

    -- If keyboard bubble is needed, add that first, else add gamepads
    table.insert(entities, bubble_controller(
      world,
      new_bubble_id,
      controller_type,
      get_bubble_position(new_bubble_id, number_available_joysticks + 1)
    ))
  end

  update_bubble_positions(entities, number_available_joysticks)
end

-- If a gamepad activates where the keyboard bubble is, move the keyboard bubble to the neighbour
-- Example: Keyboard bubble is the first bubble for display, but the first player to activate is a gamepad
-- The first bubble will become a gamepad, and the next bubble to it becomes a keyboard bubble, the first bubble will then be removed
local function move_keyboard_bubble(entity, next_entity)
  next_entity[components.animation][ANIMATION_STATE_TYPES.IDLE] = entity[components.animation][
      ANIMATION_STATE_TYPES.IDLE]
  next_entity[components.player_data].controller_type = CONTROLLER_TYPES.KEYBOARD
  entity[components.player_data].controller_type = CONTROLLER_TYPES.GAMEPAD
end

-- If the keyboard activates where a gamepad bubble is, switch the gamepad bubble with the keyboard bubble
-- Example: Keyboard bubble is the second bubble, and the first player to activate is a keyboard
-- The first bubble will become a keyboard, and the keyboard bubble (second bubble) will become a gamepad, the first bubble will then be removed
local function remove_keyboard_bubble(entities, entity_to_remove)
  local keyboard_bubble = get_keyboard_bubble(entities)

  if keyboard_bubble then
    keyboard_bubble[components.animation][ANIMATION_STATE_TYPES.IDLE] = entity_to_remove[components.animation][
        ANIMATION_STATE_TYPES.IDLE]
    keyboard_bubble[components.player_data].controller_type = CONTROLLER_TYPES.GAMEPAD
    entity_to_remove[components.player_data].controller_type = CONTROLLER_TYPES.KEYBOARD
  end
end

-- Destroys bubble entities
local function destroy_bubbles(world, entities, expected_number_of_bubbles, spawn_player)
  local active_controllers = player_input.get_active_controllers()
  local entity, player_data, active_controller = nil, nil, nil

  -- As long as there's something to remove, keep removing
  while #entities > expected_number_of_bubbles do
    for entity_index = #entities, 1, -1 do
      entity = entities[entity_index]
      player_data = entity[components.player_data]

      -- Removing all the bubbles that has become active
      for controller_index = 1, #active_controllers do
        active_controller = active_controllers[controller_index]

        if player_data.player_id == active_controller.player_id then
          if spawn_player then
            local spawn_position = entity[components.position] + vector2(0.5, 1)
            active_controller.connected_player = player(world, player_data.player_id, spawn_position, 1)
          end

          -- Moves/removes the keyboard bubble if needed
          if player_input.is_keyboard(player_data.controller_type) and not player_input.is_keyboard_active() then
            move_keyboard_bubble(entity, entities[entity_index + 1])
          elseif player_input.is_gamepad(player_data.controller_type) and player_input.is_keyboard_active() then
            remove_keyboard_bubble(entities, entity)
          end

          audio:play("bubble_burst.wav")
          table.remove(entities, entity_index)
          entity:destroy()
          return
        end
      end
    end

    remove_disconnected_joysticks(entities)
    update_bubble_positions(entities, #player_input.get_available_joysticks())
  end
end

-- Removes all the bubbles
local function destroy_all(entities)
  for entity_index = #entities, 1, -1 do
    entities[entity_index]:destroy()
  end
end

-- Rearrange the ids of the bubbles, is called when a joystick has been disconnected
-- Example: Joystick 2 becomes disconnected, then joystick 3 becomes joystick 2 and so on
local function rearrange_bubble_ids(entities, from_player_id)
  if from_player_id > 0 then
    entities = sort_entities(entities)

    for index = 1, #entities do
      local player_data = entities[index][components.player_data]
      if player_data.player_id > from_player_id then
        player_data.player_id = get_bubble_id(entities)
      end
    end

    update_bubble_positions(entities, #player_input.get_available_joysticks())
  end
end

-- Disable keypressed, joystickpressed and joystickremoved events
local function disable_controller_events(self)
  if self.player_key_pressed_event then
    game_event_manager.remove_listener(GAME_EVENT_TYPES.KEY_PRESSED, self.player_key_pressed_event)
    self.player_key_pressed_event = nil
  end

  if self.player_joystick_pressed_event then
    game_event_manager.remove_listener(GAME_EVENT_TYPES.JOYSTICK_PRESSED, self.player_joystick_pressed_event)
    self.player_joystick_pressed_event = nil
  end

  if self.player_joystick_removed_event then
    game_event_manager.remove_listener(GAME_EVENT_TYPES.JOYSTICK_REMOVED, self.player_joystick_removed_event)
    self.player_joystick_removed_event = nil
  end
end

-- Enable keypressed, joystickpressed, joystickremoved events
local function enable_controller_events(self)
  disable_controller_events(self) -- Removes them if they already exists

  -- When keyboard key is pressed
  self.player_key_pressed_event = function()
    player_input.toggle_player_activation(CONTROLLER_TYPES.KEYBOARD)
  end

  -- When joystick button is pressed
  self.player_joystick_pressed_event = function(joystick)
    player_input.toggle_player_activation(CONTROLLER_TYPES.GAMEPAD, joystick)
  end

  -- When joystick is disconnected
  self.player_joystick_removed_event = function(joystick)
    rearrange_bubble_ids(
      self:to_list(bubble_controller.get_archetype()),
      player_input.deactivate_controller(CONTROLLER_TYPES.GAMEPAD, joystick)
    )
  end

  game_event_manager.add_listener(GAME_EVENT_TYPES.KEY_PRESSED, self.player_key_pressed_event)
  game_event_manager.add_listener(GAME_EVENT_TYPES.JOYSTICK_PRESSED, self.player_joystick_pressed_event)
  game_event_manager.add_listener(GAME_EVENT_TYPES.JOYSTICK_REMOVED, self.player_joystick_removed_event)
end

return {
  sort_entities = sort_entities,
  destroy_all = destroy_all,
  create_bubbles = create_bubbles,
  destroy_bubbles = destroy_bubbles,
  disable_controller_events = disable_controller_events,
  enable_controller_events = enable_controller_events,
}

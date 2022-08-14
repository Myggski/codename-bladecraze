local event_callbacks = {}

local function add_listener(game_event_type, callback)
  event_callbacks[game_event_type] = event_callbacks[game_event_type] or {}
  table.insert(event_callbacks[game_event_type], callback)
end

local function remove_listener(game_event_type, callback)
  local event_callback = event_callbacks[game_event_type]
  local index = table.index_of(event_callback, callback)

  if (index) then
    table.remove(event_callback, index)
  end
end

local function invoke(game_event_type, ...)
  local event_callback = event_callbacks[game_event_type]

  if (event_callback and #event_callback) then
    for index = 1, #event_callback do
      event_callback[index](...)
    end
  end
end

return {
  add_listener = add_listener,
  remove_listener = remove_listener,
  invoke = invoke,
}

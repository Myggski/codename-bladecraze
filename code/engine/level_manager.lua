local level_manager = {
  _levels = nil,
  _current_level = nil
}
level_manager.__index = level_manager

function level_manager:initialize(levels)
  self._levels = levels
  self._current_level = levels[1]
  self._current_level.load()
end

function level_manager:_level_setup(selected_level)
  self._current_level.destroy()
  self._current_level = selected_level
  self._current_level.load()
end

function level_manager:_load_by_id(level_id)
  local selected_level = self._levels[level_id]

  if not selected_level then
    return
  end

  self:_level_setup(selected_level)
end

function level_manager:_load_by_name(level_name)
  local selected_level = nil

  for index = 1, #self._levels do
    if self._levels[index].name == level_name then
      selected_level = self._levels[index]
      break
    end
  end

  if not selected_level then
    return
  end

  self:_level_setup(selected_level)
end

function level_manager:reload_level()
  self._current_level.destroy()
  self._current_level.load()
end

-- level_identifier can be index of the level or name of the level
function level_manager:load_level(level_identifier)
  local level_id_type = type(level_identifier)
  if level_id_type == "string" then
    self:_load_by_name(level_identifier)
  elseif level_id_type == "number" then
    self:_load_by_id(level_identifier)
  end
end

return level_manager

local position_system = {
  _entities = {}
}

function position_system.get_system_id() return "position_system" end

function position_system:add(entity, start_vector)
  local new_entity = setmetatable({
    id = entity(),
    position = start_vector,
  }, {})
  self._entities[entity()] = new_entity
  entity:add_component(self:get_system_id())

  return new_entity
end

function position_system:remove(entity)
  self._entities[entity()] = nil
end

function position_system:get(entity)
  return self._entities[entity()]
end

function position_system:set(entity, vector)
  self._entities[entity()].position = vector
end

return position_system

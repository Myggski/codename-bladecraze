local entity = require "code.engine.entity"

local entity_manager = {
  _entities = {},
  _last_entity_id = 0,
}

function entity_manager:create()
  entity_manager._last_entity_id = entity_manager._last_entity_id + 1

  local new_entity = entity(entity_manager._last_entity_id)
  self[new_entity] = new_entity

  return new_entity
end

function entity_manager:get(id) return self._entities[id] end

function entity_manager:is_alive(id) return not (self._entities[id] == nil) end

function entity_manager:destroy(entity)
  if not (entity_manager.is_alive(entity())) then
    return
  end

  self._entities[entity()] = nil
  entity = nil
end

return entity_manager

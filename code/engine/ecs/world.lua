local entity = require "code.engine.ecs.entity"
local world = {}
local world_meta = {
  __index = world,
}

function world:entity()
  self._last_entity_id = self._last_entity_id + 1
  self._entities[self._last_entity_id] = entity(self._last_entity_id, self.is_entity_alive, self.destroy_entity)

  return self._entities[self._last_entity_id]
end

function world:is_entity_alive(e)
  return not (self._entities[e] == nil)
end

function world:destroy_entity(e)
  if not (self.is_entity_alive(e)) then
    return
  end

  self._entities[e] = nil
  e = nil
end

function world:get(query)
  if query.is_query_builder then
    query = query.build()
  end

  if not query.is_query then
    return self._entities
  end

  local entities = {}

  for _, entity in pairs(self._entities) do
    if query:match(entity) then
      table.insert(entities, entity)
    end
  end

  return entities
end

local function create_world()
  return setmetatable({
    _entities = {},
    _systems = {},
    _last_entity_id = 0,
  }, world_meta)
end

return setmetatable({ create = create_world, }, { __call = function(_, _) return create_world() end })

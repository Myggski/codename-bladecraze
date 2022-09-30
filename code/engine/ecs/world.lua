local entity = require "code.engine.ecs.entity"
local world_type = {}
local world_meta = {
  __index = world_type,
}

function world_type:entity()
  local entity_id = 0

  if #self._destroyed_entity_ids > 0 then
    entity_id = self._destroyed_entity_ids[1]
    table.remove(self._destroyed_entity_ids, 1)
  else
    entity_id = self._last_entity_id + 1
    self._last_entity_id = entity_id
  end

  self._entities[self._last_entity_id] = entity(entity_id, self.is_entity_alive, self.destroy_entity)

  return self._entities[self._last_entity_id]
end

function world_type:is_entity_alive(e)
  return not (self._entities[e] == nil)
end

function world_type:destroy_entity(e)
  if not (self.is_entity_alive(e)) then
    return
  end

  self._entities[e] = nil
  table.insert(self._destroyed_entity_ids, e:get_id())

  setmetatable(e, nil)
  for k in pairs(e) do
    e[k] = nil
  end
end

function world_type:destroy()
  for _, entity in pairs(self._entities) do
    entity:destroy()
  end

  for _, system in pairs(self._systems) do
    system:destroy()
  end

  self._systems = {}
end

function world_type:get(query)
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
  local world = setmetatable({
    _entities = {},
    _destroyed_entity_ids = {},
    _systems = {},
    _last_entity_id = 0,
  }, world_meta)

  function world:add_system(system_type)
    if self._systems[system_type] == nil then
      self._systems[system_type] = system_type(self)
    end
  end

  function world:remove_system(system_type)
    if not (self._systems[system_type] == nil) then
      self._systems[system_type] = nil
    end
  end

  function world:update(dt)
    for _, system in pairs(self._systems) do
      system:update(dt)
    end
  end

  return world
end

return setmetatable({ create = create_world, }, { __call = function(_, _) return create_world() end })

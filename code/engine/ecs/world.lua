local entity = require "code.engine.ecs.entity"
local world_type = {}
local world_meta = {
  __index = world_type,
}

-- Returns a unique id for entities
function world_type:get_entity_id()
  local entity_id = 0

  if #self._destroyed_entity_ids > 0 then
    entity_id = self._destroyed_entity_ids[1]
    table.remove(self._destroyed_entity_ids, 1)
  else
    entity_id = self._last_entity_id + 1
    self._last_entity_id = entity_id
  end

  return entity_id
end

-- Creates an entity and adds it into the world
function world_type:entity(...)
  local id = self:get_entity_id()
  local new_entity = entity(
    id,
    self.is_entity_alive,
    self.destroy_entity,
    ...
  )

  if not self._entities[new_entity.archetype] then
    self._entities[new_entity.archetype] = { [id] = new_entity }
  else
    self._entities[new_entity.archetype][id] = new_entity
  end

  return new_entity
end

-- Checks if the entity is alive
function world_type:is_entity_alive(e)
  return not (self._entities[e.archetype][e:get_id()] == nil)
end

-- Removes the entity from the world
function world_type:destroy_entity(e)
  if not (self.is_entity_alive(e)) then
    return
  end

  self._entities[e.archetype][e:get_id()] = nil
  table.insert(self._destroyed_entity_ids, e:get_id())

  setmetatable(e, nil)
  for k in pairs(e) do
    e[k] = nil
  end
end

-- Destroys the entire world
function world_type:destroy()
  for _, entity in pairs(self._entities) do
    entity:destroy()
  end

  for _, system in pairs(self._systems) do
    system:destroy()
  end

  self._systems = {}
end

function world_type:for_each_entity(query, action)
  local index = 1

  for archetype, entities in pairs(self._entities) do
    if query:has_valid_archetype(archetype) then
      for _, entity in pairs(entities) do
        if query:match(entity) then
          action(entity, index)
          index = index + 1
        end
      end
    end
  end
end

-- Generating the world
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

    -- Update the archetype list if needed
    -- TODO: Optimize this with events or in some other way
    -- It doesn'have to be checked in every update
    for archetype, entities in pairs(self._entities) do
      for _, entity in pairs(entities) do
        if not (entity.archetype == archetype) then
          self._entities[archetype][entity:get_id()] = nil

          if self._entities[entity.archetype] then
            self._entities[entity.archetype][entity:get_id()] = entity
          else
            self._entities[entity.archetype] = { [entity:get_id()] = entity }
          end
        end
      end
    end
  end

  return world
end

return setmetatable({ create = create_world, }, { __call = function(_, _) return create_world() end })

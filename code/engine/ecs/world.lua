local entity = require "code.engine.ecs.entity"

local world_type = {}
local world_meta = {
  __index = world_type,
}

-- Returns a unique id for entities
function world_type:generate_entity_id()
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
  local id = self:generate_entity_id()
  local new_entity = entity(
    id,
    self:destroy_entity_callback(),
    self:entity_archetype_changed_callback(),
    ...
  )

  self:_add_entity_to_archetype(new_entity)

  return new_entity
end

-- Removes the entity from the world
function world_type:destroy_entity_callback()
  local self_world = self

  return function(e)
    if not e:is_alive() then
      return
    end

    table.insert(self_world._destroyed_entity_ids, e:get_id())
    table.insert(self_world._destroyed_entities, e)

    e._id = -1
  end
end

function world_type:entity_archetype_changed_callback()
  local self_world = self

  return function(e, old_archetype)
    table.insert(self_world._changed_entity_data_list, { entity = e, old_archetype = old_archetype })
  end
end

-- Destroys the entire world
function world_type:destroy()
  for archetype_index = 1, #self._entity_data do
    for entity_index = 1, #self._entity_data[archetype_index].entities do
      self._entity_data[archetype_index].entities[entity_index]:destroy()
    end
  end

  for _, system in pairs(self._systems) do
    system:destroy()
  end

  self._systems = {}
end

-- Generating the world
local function create_world()
  local world = setmetatable({
    _entity_data = {},
    _destroyed_entity_ids = {},
    _destroyed_entities = {},
    _changed_entity_data_list = {},
    _systems = {},
    _system_keys = {}, -- To make sure that the sytems are called in correct order
    _last_entity_id = 0,
  }, world_meta)

  function world:_find_archetype(archetype)
    local archetype_index = -1

    for index = 1, #self._entity_data do
      if self._entity_data[index].archetype == archetype then
        archetype_index = index
        break
      end
    end

    return archetype_index
  end

  function world:_add_entity_to_archetype(entity)
    local index = self:_find_archetype(entity.archetype)

    if index == -1 then
      table.insert(self._entity_data, { archetype = entity.archetype, entities = { entity } })
    else
      table.insert(self._entity_data[index].entities, entity)
    end
  end

  -- Adds a system to the world
  function world:add_system(system_type)
    if not self._systems[system_type] and system_type.is_system_type then
      table.insert(self._system_keys, system_type)
      self._systems[system_type] = system_type(self)
    end
  end

  -- Removes a system from the world
  function world:remove_system(system_type)
    self._systems[system_type] = nil
    table.remove(self._system_keys, table.index_of(self._system_keys, system_type))
  end

  function world_type:for_each(query, action)
    local index = 1
    local entities, archetype_entities, entity = {}, {}, nil
    action = type(action) == "function" and action or function(_, _) end

    if query.is_query_builder then
      query = query.build()
    end

    for archetype_index = 1, #self._entity_data do
      if query:is_valid_archetype(self._entity_data[archetype_index].archetype) then
        archetype_entities = self._entity_data[archetype_index].entities
        for entity_index = 1, #archetype_entities do
          entity = archetype_entities[entity_index]
          if query:is_entity_valid(entity) then
            index = index + 1
            table.insert(entities, entity)

            action(entity, index)
          end
        end
      end
    end

    return entities
  end

  --[[ 
    This is called every tick
    It saves the system keys in seperate table to make sure that the systems run same sequal every time
    This also makes the loop more stable, with pairs the call-time jumps up sometimes for some reason
  ]]
  function world:update(dt)
    for index = 1, #self._system_keys do
      self._systems[self._system_keys[index]]:update(dt)
    end

    local changed_entity_data, archetype_index, entity_index = nil, -1, -1

    for index = #self._changed_entity_data_list, 1, -1 do
      changed_entity_data = self._changed_entity_data_list[index]
      archetype_index = self:_find_archetype(changed_entity_data.old_archetype)

      if archetype_index > 0 then
        entity_index = table.index_of(self._entity_data[archetype_index].entities, changed_entity_data.entity)

        if entity_index > 0 then
          self._entity_data[archetype_index][entity_index] = nil
          self:_add_entity_to_archetype(changed_entity_data.entity)
        end
      end

      table.remove(self._changed_entity_data_list, index)
    end

    local destroyed_entity, archetype_index, entity_index = nil, -1, -1

    -- Evaporate the dead completely from this world
    for index = 1, #self._destroyed_entities do
      destroyed_entity = self._destroyed_entities[index]
      archetype_index = self:_find_archetype(destroyed_entity.archetype)

      if archetype_index == -1 then
        return
      end

      entity_index = table.index_of(self._entity_data[archetype_index].entities, destroyed_entity)

      if entity_index == -1 then
        return
      end

      table.remove(self._entity_data[archetype_index].entities, entity_index)
      self._destroyed_entities[index] = nil
    end
  end

  return world
end

return setmetatable({ create = create_world, }, { __call = function(_, _) return create_world() end })

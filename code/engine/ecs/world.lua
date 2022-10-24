local entity = require "code.engine.ecs.entity"

local world_type = {}
local world_meta = {
  __index = world_type,
}

-- Returns a unique id for entities
local function generate_entity_id(world)
  local entity_id = 0

  if #world._destroyed_entity_ids > 0 then
    entity_id = world._destroyed_entity_ids[1]
    table.remove(world._destroyed_entity_ids, 1)
  else
    entity_id = world._last_entity_id + 1
    world._last_entity_id = entity_id
  end

  return entity_id
end

local function find_archetype(world, archetype)
  local archetype_index = -1

  for index = 1, #world._entity_data do
    if world._entity_data[index].archetype == archetype then
      archetype_index = index
      break
    end
  end

  return archetype_index
end

local function add_entity_to_archetype(world, entity)
  local index = find_archetype(world, entity.archetype)

  if index == -1 then
    table.insert(world._entity_data, { archetype = entity.archetype, entities = { entity } })
  else
    table.insert(world._entity_data[index].entities, entity)
  end
end

local function delete_entities(world)
  local destroyed_entity, archetype_index, entity_index, changed_index = nil, -1, -1, -1

  -- Evaporate the dead completely from this world
  for index = #world._destroyed_entities, 1, -1 do
    destroyed_entity = world._destroyed_entities[index]
    archetype_index = find_archetype(world, destroyed_entity.archetype)

    if archetype_index == -1 then
      return
    end

    entity_index = table.index_of(world._entity_data[archetype_index].entities, destroyed_entity)

    if entity_index == -1 then
      return
    end

    table.remove(world._entity_data[archetype_index].entities, entity_index)
    world._destroyed_entities[index] = nil

    changed_index = table.index_of(world._changed_entity_data_list, destroyed_entity)

    -- Remove entity from the changelist if it's being deleted
    if changed_index > 0 then
      table.remove(world._changed_entity_data_list, changed_index)
    end
  end
end

-- Move entity to correct archetype group
local function update_entities(world)
  local changed_entity_data, archetype_index, entity_index = nil, -1, -1

  for index = #world._changed_entity_data_list, 1, -1 do
    changed_entity_data = world._changed_entity_data_list[index]
    archetype_index = find_archetype(world, changed_entity_data.old_archetype)

    if archetype_index > 0 then
      entity_index = table.index_of(world._entity_data[archetype_index].entities, changed_entity_data.entity)

      if entity_index > 0 then
        world._entity_data[archetype_index][entity_index] = nil
        add_entity_to_archetype(world, changed_entity_data.entity)
      end
    end

    table.remove(world._changed_entity_data_list, index)
  end
end

-- Creates an entity and adds it into the world
function world_type:entity(...)
  local id = generate_entity_id(self)
  local new_entity = entity(
    id,
    self:destroy_entity_callback(),
    self:entity_archetype_changed_callback(),
    ...
  )

  add_entity_to_archetype(self, new_entity)
  self._number_of_entities = self._number_of_entities + 1

  return new_entity
end

local function destroy_entity(world, e)
  if not e:is_alive() then
    return
  end

  table.insert(world._destroyed_entity_ids, e:get_id())
  table.insert(world._destroyed_entities, e)
  e._id = -1
end

-- Removes the entity from the world
function world_type:destroy_entity_callback()
  local self_world = self

  return function(e) destroy_entity(self_world, e) end
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
      destroy_entity(self, self._entity_data[archetype_index].entities[entity_index])
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
    _number_of_entities = 0,
    _entity_data = {},
    _destroyed_entity_ids = {},
    _destroyed_entities = {},
    _changed_entity_data_list = {},
    _systems = {},
    _system_keys = {}, -- To make sure that the sytems are called in correct order
    _last_entity_id = 0,
  }, world_meta)

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

  function world_type:to_list(query)
    local entities, archetype_entities, entity = {}, {}, nil

    if query.is_query_builder then
      query = query.build()
    end

    for archetype_index = 1, #self._entity_data do
      if query:is_valid_archetype(self._entity_data[archetype_index].archetype) then
        archetype_entities = self._entity_data[archetype_index].entities
        for entity_index = 1, #archetype_entities do
          entity = archetype_entities[entity_index]
          if query:is_entity_valid(entity) then
            table.insert(entities, entity)
          end
        end
      end
    end

    return entities
  end

  local function get_entity_index(world, current_index)
    local total_entities, number_of_entities = 0, 0

    for archetype_index = 1, #world._entity_data do
      number_of_entities = #world._entity_data[archetype_index].entities

      if current_index <= total_entities + number_of_entities then
        return archetype_index, (total_entities + number_of_entities - current_index) + 1
      end

      total_entities = total_entities + number_of_entities
    end

    return 1, 1
  end

  function world_type:for_each(query, action)
    local archetype_entities = {}
    action = type(action) == "function" and action or function(_, _) end

    if query.is_query_builder then
      query = query.build()
    end

    local archetype_index, entity_index = -1, -1

    for index = self._number_of_entities, 1, -1 do
      archetype_index, entity_index = get_entity_index(self, index)

      if query:is_valid_archetype(self._entity_data[archetype_index].archetype) then
        archetype_entities = self._entity_data[archetype_index].entities
        if query:is_entity_valid(archetype_entities[entity_index]) then
          index = index + 1
          action(archetype_entities[entity_index], index)
        end
      end
    end
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

    delete_entities(self)
    update_entities(self)
  end

  return world
end

return setmetatable({ create = create_world, }, { __call = function(_, _) return create_world() end })

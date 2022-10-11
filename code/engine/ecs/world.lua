local entity = require "code.engine.ecs.entity"
local archetype = require "code.engine.ecs.archetype"

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

    local archetype_index = self_world:_find_archetype(e.archetype)

    if archetype_index == -1 then
      return
    end

    local entity_list = self_world._entity_data[archetype_index].entities
    local entity_index = table.index_of(entity_list, e)

    if entity_index == -1 then
      return
    end

    self_world._entity_data[archetype_index].entities[entity_index] = nil
    e._id = -1
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

  -- This method should be called inside a coroutine in order to work as intended
  -- Check system.lua and entities_coroutine to see the setup
  function world_type:for_each_entity(query, action)
    local index = 1

    for archetype_index = 1, #self._entity_data do
      if query:is_valid_archetype(self._entity_data[archetype_index].archetype) then
        for entity_index = 1, #self._entity_data[archetype_index].entities do
          if query:is_entity_valid(self._entity_data[archetype_index].entities[entity_index]) then
            action(self._entity_data[archetype_index].entities[entity_index], index)
            index = index + 1
          end
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

    -- Update the archetype list if needed
    -- TODO: Optimize this with events or in some other way
    -- It doesn'have to be checked in every update
    local current_entity = nil
    local entity_list = nil

    for archetype_index = 1, #self._entity_data do
      entity_list = self._entity_data[archetype_index].entities
      for entity_index = 1, #entity_list do
        current_entity = entity_list[entity_index]
        if not (current_entity.archetype == entity_list.archetype) then
          self._entity_data[archetype_index].entities[entity_index] = nil
          self:_add_entity_to_archetype(current_entity)
        end
      end
    end

    -- Evaporate the dead completely from this world
    for index = 1, #self._destroyed_entities do
      self._destroyed_entities[index] = nil
    end
  end

  return world
end

return setmetatable({ create = create_world, }, { __call = function(_, _) return create_world() end })

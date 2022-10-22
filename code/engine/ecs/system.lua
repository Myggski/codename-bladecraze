local system_type_meta = { __call = function(st, ...) return st.create(...) end }
local SYSTEM_ID = 0
local destroyed_systems_ids = {}

-- Creates a system type
-- Examples of system_types = input_system, movement_system and so on
local function create_system_type(query, update_fn)
  local system_id = 0

  -- Reuses ids of destroyed systems
  if #destroyed_systems_ids > 0 then
    system_id = destroyed_systems_ids[1]
    table.remove(destroyed_systems_ids, 1)
  else
    system_id = SYSTEM_ID + 1
    SYSTEM_ID = system_id
  end

  SYSTEM_ID = SYSTEM_ID + 1

  if type(query) == "function" and not update_fn then
    update_fn = query
    query = nil
  end

  local system_type = {
    _id = SYSTEM_ID,
    is_system_type = true,
    query = query,
    update = update_fn
  }
  system_type.__index = system_type

  -- Creates a system, to get access of the entites in the world that it has been added to
  -- This function is only called when it gets added to the world
  function system_type.create(world)
    local system = setmetatable({
      _world = world,
    }, system_type)

    -- Returns all the matching entities in a list
    function system:to_list(query)
      return self._world:to_list(query or system_type.query)
    end

    -- Calls a action function for every matching entity
    function system:for_each(action, query)
      self._world:for_each(action, query or system_type.query)
    end

    function system:archetype_for_each(archetype, action)
      self._world:archetype_for_each(archetype, action)
    end

    -- Returns the world
    function system:get_world()
      return self._world
    end

    -- If the system has a on_call function, call it when the system is being added to the world
    if system.on_start then
      system:on_start()
    end

    return system
  end

  -- Get system type
  function system_type:get_type()
    return system_type
  end

  -- Destroys the system and everything that's in it
  function system_type:destroy()
    -- If the system has a on_destroy function, call it when the system is being destroyed in the world
    if system_type.on_destroy then
      system_type:on_destroy()
    end

    table.insert(destroyed_systems_ids, self._id)
    self._world:remove_system(self:get_type())

    setmetatable(self, nil)
    for k in pairs(self) do
      self[k] = nil
    end
  end

  return setmetatable(system_type, system_type_meta)
end

return setmetatable({ create = create_system_type, },
  { __call = function(_, ...) return create_system_type(...) end })

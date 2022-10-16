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

    function system:entity_iterator(query)
      query = query or system_type.query

      local entities_coroutine = coroutine.create(function()
        self._world:to_list(query or system_type.query, function(value, count)
          coroutine.yield(value, count)
        end)
      end)

      return function()
        local _, item, index = coroutine.resume(entities_coroutine)
        return index, item
      end
    end

    function system:to_list(query)
      return self._world:to_list(query or system_type.query)
    end

    function system:get_world()
      return self._world
    end

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

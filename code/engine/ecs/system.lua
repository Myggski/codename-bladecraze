local system_type_meta = { __call = function(st, ...) return st.create(...) end }
local SYSTEM_ID = 0
local destroyed_systems_ids = {}

local function create_system_type(query, update_fn)
  local system_id = 0

  if #destroyed_systems_ids > 0 then
    system_id = destroyed_systems_ids[1]
    table.remove(destroyed_systems_ids, 1)
  else
    system_id = SYSTEM_ID + 1
    SYSTEM_ID = system_id
  end

  SYSTEM_ID = SYSTEM_ID + 1

  if type(query) == "function" and update_fn == nil then
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

  function system_type.create(world)
    local system = setmetatable({
      _world = world,
    }, system_type)

    function system:entities(query)
      return self._world:get(query or system_type.query)
    end

    return system
  end

  function system_type:get_type()
    return system_type
  end

  function system_type:destroy()
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

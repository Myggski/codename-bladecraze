local component_type_meta = { __call = function(ct, ...) return ct.create(...) end }
local COMPONENT_ID = 0

local function create_component(value)
  return { value = value }
end

-- Creates a new component type
-- Examples of type: position, size, acceleration, speed and so on
local function create_component_type(default_value)
  COMPONENT_ID = COMPONENT_ID + 1

  local component_type = {
    _id = COMPONENT_ID,
    is_component_type = true,
    value = default_value or {},
  }
  component_type.__index = component_type

  -- Creates a new component out of a component type
  -- Example of type: player_position = position_component()
  function component_type.create(value)
    -- Deep clones the default value if its a table
    if not value and type(default_value) == "table" then
      value = table.deep_clone(default_value)
    end

    local component = setmetatable(create_component(value), component_type)
    component.is_component = true

    return component
  end

  -- Get the type of component
  function component_type:get_type()
    return component_type
  end

  -- Get component id
  function component_type:get_id()
    return self._id
  end

  -- Checks if the component is of type
  function component_type:is(ct)
    return component_type == ct
  end

  return setmetatable(component_type, component_type_meta)
end

return setmetatable({ create = create_component_type, },
  { __call = function(_, ...) return create_component_type(...) end })

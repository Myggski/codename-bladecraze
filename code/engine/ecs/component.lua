local component_type_meta = { __call = function(ct, ...) return ct.create(...) end }
local COMPONENT_ID = 0

local function create_component(value)
  return value and { value = value } or {}
end

local function create_component_type(default_value)
  COMPONENT_ID = COMPONENT_ID + 1

  local component_type = {
    _id = COMPONENT_ID,
    is_component_type = true,
    value = default_value or {},
  }
  component_type.__index = component_type

  function component_type.create(value)
    local component = setmetatable(create_component(value), component_type)
    component.is_component = true

    return component
  end

  function component_type:get_type()
    return component_type
  end

  function component_type:is(ct)
    return component_type == ct
  end

  return setmetatable(component_type, component_type_meta)
end

return setmetatable({ create = create_component_type, },
  { __call = function(_, ...) return create_component_type(...) end })

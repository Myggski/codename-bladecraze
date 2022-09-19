local component = {
  _id = 0,
  value = nil
}
local component_meta = {
  __index = component,
  __call = function(t, ...) return t.value end
}
local COMPONENT_ID = 0

local function create(template_value)
  COMPONENT_ID = COMPONENT_ID + 1

  return setmetatable({
    _id = COMPONENT_ID,
    value = template_value,
  }, component_meta)
end

return setmetatable({ create = create, }, { __call = function(_, ...) return create(...) end })

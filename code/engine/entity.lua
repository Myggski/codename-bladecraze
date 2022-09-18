local entity = {}

local entity_meta = {
  __index = entity,
  __call = function(t, ...) return not (t == nil) and t.id or nil end
}

function entity:add_component(component_id)
  self.components[component_id] = component_id
end

function entity:remove_component(component_id)
  self.components[component_id] = nil
end

function entity:has_component(component_id)
  return not (self.components[component_id] == nil)
end

local create = function(id)
  assert(not (id == nil), "Error, an id expected, got: " .. id)

  return setmetatable({
    id = id,
    components = {},
  }, entity_meta)
end

return setmetatable({ create = create }, { __call = function(_, ...) return create(...) end })

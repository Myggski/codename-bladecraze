local entity_meta = {
  __index = function(entity, key)
    if type(key) == "table" and entity.has_component(entity, key) then
      return entity.components[key].value
    end
  end,
  __newindex = function(entity, key, value)
    if type(key) == "table" then -- TODO: Do better check to see if the key is a component
      entity.add_component(entity, key, value)
    else
      rawset(entity, key, value)
    end
  end,
}

local function add_component(entity, component, value)
  value = value or component.value

  component.value = value
  entity.components[component] = component
end

local function remove_component(entity, component)
  entity.components[component] = nil
end

local function has_component(entity, component)
  return not (entity.components[component] == nil)
end

local create = function(id)
  assert(not (id == nil), "Error, an id expected, got: " .. id)

  return setmetatable({
    _id = id,
    components = {},
    add_component = add_component,
    remove_component = remove_component,
    has_component = has_component,
  }, entity_meta)
end

return setmetatable({ create = create }, { __call = function(_, ...) return create(...) end })

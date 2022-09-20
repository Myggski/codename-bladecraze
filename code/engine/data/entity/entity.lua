local function add_component(entity, key, value)
  if key and key.is_type and not key.is_component then
    if value == nil and entity:has_component(key) then
      entity:remove_component(key)
    elseif type(value) == "table" and value.is_component then
      entity.components[key] = value
    else
      entity[key] = key(value)
    end
  end
end

local function remove_component(entity, component)
  entity.components[component] = nil
end

local function has_component(entity, component)
  return not (entity.components[component] == nil)
end

local entity_meta = {
  __index = function(entity, key)
    print(entity, key, type(key), entity.has_component(entity, key))
    if type(key) == "table" and entity.has_component(entity, key) then
      return entity.components[key].value
    end
  end,
  __newindex = function(entity, key, value)
    add_component(entity, key, value)
  end
}

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

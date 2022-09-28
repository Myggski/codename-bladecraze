local function add_component(entity, key, value)
  if key and key.is_component_type and not key.is_component then
    if value == nil and entity:has_component(key) then
      entity:remove_component(key)
    elseif type(value) == "table" and value.is_component then
      entity._components[key] = value
    else
      entity[key] = key(value)
    end
  end
end

local function remove_component(entity, component)
  entity._components[component] = nil
end

local function has_component(entity, component)
  return not (entity._components[component] == nil)
end

local function has_components(entity, ...)
  local components = (...).is_component_type and { ... } or ...

  for _, component in pairs(components) do
    if not entity:has_component(component) then
      return false
    end
  end

  return true
end

local function has_any_components(entity, ...)
  local components = (...).is_component_type and { ... } or ...

  for _, component in pairs(components) do
    if entity:has_component(component) then
      return true
    end
  end

  return false
end

local function get_id(entity) return entity._id end

local entity_meta = {
  __index = function(entity, key)
    if type(key) == "table" and entity:has_components(key) then
      return entity._components[key].value
    end
  end,
  __newindex = function(entity, key, value)
    add_component(entity, key, value)
  end
}

local create = function(id, is_alive_callback, destroy_callback)
  assert(not (id == nil), "Error, an id expected, got: " .. id)
  assert(not (destroy_callback == nil), "Error, entity needs a destroy_callback function set")
  assert(not (is_alive_callback == nil), "Error, entity needs a is_alive_callback function set")

  local entity = {
    _id = id,
    _components = {},
    get_id = get_id,
    add_component = add_component,
    remove_component = remove_component,
    has_component = has_component,
    has_components = has_components,
    has_any_components = has_any_components,
    destroy = destroy_callback,
    is_alive = is_alive_callback,
  }

  return setmetatable(entity, entity_meta)
end

return setmetatable({ create = create }, { __call = function(_, ...) return create(...) end })

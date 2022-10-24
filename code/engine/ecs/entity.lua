local archetype = require "code.engine.ecs.archetype"

-- Adds list of components, all at once
local function add_components(entity, ...)
  local components = { ... }
  local new_archetype = nil
  local component = nil

  for index = 1, #components do
    component = components[index]
    assert(type(component) == "table" and component.is_component,
      "Invalid components param, param is not a component")

    entity._component_values[component.get_type()] = component
    new_archetype = new_archetype and new_archetype:add(component.get_type())
        or entity.archetype:add(component.get_type())
  end

  if not (entity.archetype == new_archetype) then
    local old_archetype = entity.archetype
    entity.archetype = new_archetype and new_archetype or archetype.EMPTY
    entity._archetype_changed(entity, old_archetype)
  end
end

-- Adds a component to an entity
-- This makes the entity change or create a new archetype
local function add_component(entity, component_type, component_value)
  assert(type(component_type) == "table" and component_type.is_component_type,
    "Invalid component type param, param is not a component_type")

  -- If the value is nil and the component exsist, remove the component
  if component_value == nil and entity:has_component(component_type) then
    entity:remove_component(component_type)
    return
  end

  -- If the value is a table and it is of type component
  if type(component_value) == "table" and component_value.is_component then
    entity._component_values[component_type] = component_value

    if not entity:has_component(component_type) then
      local new_archetype = entity.archetype:add(component_type)

      if not (entity.archetype == new_archetype) then
        local old_archetype = entity.archetype
        entity.archetype = new_archetype
        entity._archetype_changed(entity, old_archetype)
      end
    end
  else
    local new_archetype = entity.archetype:add(component_type)
    entity[component_type] = component_type(component_value)

    if not (entity.archetype == new_archetype) then
      local old_archetype = entity.archetype
      entity.archetype = new_archetype
      entity._archetype_changed(entity, old_archetype)
    end
  end
end

-- Removes a component to an entity
-- This makes the entity change or create a new archetype
local function remove_component(entity, component_type)
  entity._component_values[component_type] = nil

  local new_archetype = entity.archetype:remove(component_type)

  if not (entity.archetype == new_archetype) then
    local old_archetype = entity.archetype
    entity.archetype = new_archetype
    entity._archetype_changed(entity, old_archetype)
  end
end

-- Checks if the entity has a specific component
local function has_component(entity, component_type)
  return entity.archetype:has(component_type)
end

-- Checks if the entity has all of the listed componets
local function has_components(entity, ...)
  return entity.archetype:has_all(...)
end

-- Checks if the entity has any of the listed components
local function has_any_components(entity, ...)
  return entity.archetype:has_any(...)
end

-- Gets the id of the entity
local function get_id(entity) return entity._id end

-- Checks if the entitiy is alive and is not about to be removed
local function is_alive(entity) return entity._id > -1 end

local entity_meta = {
  __index = function(entity, key)
    if type(key) == "table" and entity:has_component(key) then
      return entity._component_values[key].value
    end

    return nil
  end,
  __newindex = function(entity, key, value)
    add_component(entity, key, value)
  end
}

-- Creates an entity
local create = function(id, destroy_callback, archetype_changed_callback, ...)
  assert(not (id == nil), "Error, an id expected, got: " .. id)
  assert(not (destroy_callback == nil), "Error, entity needs a destroy_callback function set")
  assert(not (archetype_changed_callback == nil), "Error, entity needs a archetype_changed_callback function set")

  local entity = {
    _id = id,
    _component_values = {},
    _archetype_changed = archetype_changed_callback,
    archetype = archetype.EMPTY,
    get_id = get_id,
    is_alive = is_alive,
    add_component = add_component,
    remove_component = remove_component,
    has_component = has_component,
    has_components = has_components,
    has_any_components = has_any_components,
    destroy = destroy_callback,
  }
  entity.__index = entity

  -- Adds all the components to the entity
  add_components(entity, ...)

  return setmetatable(entity, entity_meta)
end

return setmetatable({ create = create }, { __call = function(_, ...) return create(...) end })

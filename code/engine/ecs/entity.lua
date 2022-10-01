local archetype = require "code.engine.ecs.archetype"

local function add_component(entity, component_type, component_value)
  if component_type and component_type.is_component_type and not component_type.is_component then
    if component_value == nil and entity:has_component(component_type) then
      entity:remove_component(component_type)
    elseif type(component_value) == "table" and component_value.is_component then
      entity._component_values[component_type] = component_value

      if not entity:has_component(component_type) then
        local new_archetype = entity.archetype:with(component_type)

        if not (entity.archetype == new_archetype) then
          entity.archetype = new_archetype
        end
      end
    else
      local new_archetype = entity.archetype:with(component_type)

      if not (entity.archetype == new_archetype) then
        entity[component_type] = component_type(component_value)
        entity.archetype = new_archetype
      end
    end
  end
end

local function remove_component(entity, component_type)
  entity._component_values[component_type] = nil

  local new_archetype = entity.archetype:without(component_type)

  if not (entity.archetype == new_archetype) then
    entity.archetype = new_archetype
  end
end

local function has_component(entity, component_type)
  return entity.archetype:has(component_type)
end

local function has_components(entity, ...)
  return entity.archetype:has_all(...)
end

local function has_any_components(entity, ...)
  return entity.archetype:has_any(...)
end

local function get_id(entity) return entity._id end

local entity_meta = {
  __index = function(entity, key)
    if type(key) == "table" and entity:has_components(key) then
      return entity._component_values[key].value
    end
  end,
  __newindex = function(entity, key, value)
    add_component(entity, key, value)
  end
}

local create = function(id, is_alive_callback, destroy_callback, ...)
  assert(not (id == nil), "Error, an id expected, got: " .. id)
  assert(not (destroy_callback == nil), "Error, entity needs a destroy_callback function set")
  assert(not (is_alive_callback == nil), "Error, entity needs a is_alive_callback function set")

  local entity = {
    _id = id,
    archetype = archetype.EMPTY,
    _component_values = {},
    get_id = get_id,
    add_component = add_component,
    remove_component = remove_component,
    has_component = has_component,
    has_components = has_components,
    has_any_components = has_any_components,
    destroy = destroy_callback,
    is_alive = is_alive_callback,
  }

  for _, component in pairs({ ... }) do
    if component.is_component then
      entity:add_component(component.get_type(), component)
    end
  end

  return setmetatable(entity, entity_meta)
end

return setmetatable({ create = create }, { __call = function(_, ...) return create(...) end })

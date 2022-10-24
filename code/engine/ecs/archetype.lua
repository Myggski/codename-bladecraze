require "code.utilities.set"

local CACHE_WITH = {}
local CACHE_WITHOUT = {}
local archetypes = {} -- All the archetypes
local version = 0 -- Archetype version, changes whenever a new type of archetype is added

local archetype = {}
archetype.__index = archetype

-- Gets already existing archetype or creates a new one
function archetype.setup(...)
  local component_types = (...).is_component_type and { ... } or ...
  local component_ids = {}
  local components = {}
  local current_component = nil

  for index = 1, #component_types do
    current_component = component_types[index]
    if not current_component.is_component_type or current_component.is_component then
      return
    end

    if not set.contains(components, current_component) then
      set.add(components, current_component)
      table.insert(component_ids, current_component:get_id())
    end
  end

  table.sort(component_ids)
  local archetype_id = table.concat(component_ids, "_")

  if archetypes[archetype_id] == nil then
    archetypes[archetype_id] = setmetatable({
      _id = archetype_id,
      _components = components,
      get_id = function(a) return a._id end,
    }, archetype)

    version = version + 1
  end

  return archetypes[archetype_id]
end

-- Adds a component to a archetype
function archetype:add(component_type)
  if set.contains(self._components, component_type) then
    return self
  end

  local archetype_cache = CACHE_WITH[self]

  if not archetype_cache then
    archetype_cache = {}
    CACHE_WITH[self] = archetype_cache
  end

  local current_archetype = archetype_cache[component_type]

  if current_archetype == nil then
    local component_types = {}

    for component, _ in pairs(self._components) do
      table.insert(component_types, component)
    end

    table.insert(component_types, component_type)
    current_archetype = archetype.setup(component_types)
    archetype_cache[component_type] = current_archetype
  end

  return current_archetype
end

-- Removes a component to a archetype
function archetype:remove(component_type)
  if not set.contains(self._components, component_type) then
    return self
  end

  local archetype_cache = CACHE_WITHOUT[self]

  if not archetype_cache then
    archetype_cache = {}
    CACHE_WITH[self] = archetype_cache
  end

  local current_archetype = archetype_cache[component_type]

  if current_archetype == nil then
    local component_types = {}

    for component, _ in pairs(self._components) do
      if not component_type:is(component) then
        table.insert(component_types, component)
      end
    end

    current_archetype = archetype.setup(component_types)
    archetype_cache[component_type] = current_archetype
  end

  return current_archetype
end

-- Get the archetype version
function archetype.get_version()
  return version
end

-- Checks if the archetype has a specific component
function archetype:has(component_type)
  return set.contains(self._components, component_type)
end

-- Checks if the archetype has all of the listed componets
function archetype:has_all(...)
  local components = (...).is_component_type and { ... } or ...

  for index = 1, #components do
    if not self:has(components[index]) then
      return false
    end
  end

  return true
end

-- Checks if the archetype has any of the listed components
function archetype:has_any(...)
  local components = (...).is_component_type and { ... } or ...

  for index = 1, #components do
    if self:has(components[index]) then
      return true
    end
  end

  return false
end

-- An empty archetype, to start with
archetype.EMPTY = archetype.setup({})

return archetype

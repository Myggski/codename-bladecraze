local entity_query = {}
entity_query.__index = entity_query

local function seperate_query_type(list)
  local components, filters = {}, {}

  for _, item in pairs(list) do
    if item.is_component_type and not item.is_component then
      table.insert(components, item)
    elseif item.is_filter then
      table.insert(filters, item)
    end
  end

  return components, filters
end

function entity_query.create(all, any, none)
  local all_filters, any_filters, none_filters

  all, all_filters = seperate_query_type(all or {})
  any, any_filters = seperate_query_type(any or {})
  none, none_filters = seperate_query_type(none or {})

  return setmetatable({
    is_query = true,
    _all_components = all,
    _all_filters = all_filters,
    _any_components = any,
    _any_filters = any_filters,
    _none_components = none,
    _none_filters = none_filters,
    _archetype_cache = {},
  }, entity_query)
end

local function query_builder()
  local builder = {
    is_query_builder = true
  }
  local query

  function builder.all(...)
    query = nil
    builder._all = { ... }
    return builder
  end

  function builder.any(...)
    query = nil
    builder._any = { ... }
    return builder
  end

  function builder.none(...)
    query = nil
    builder._none = { ... }
    return builder
  end

  function builder.build()
    if query == nil then
      query = entity_query.create(builder._all, builder._any, builder._none)
    end
    return query
  end

  return builder
end

function entity_query.all(...)
  return query_builder().all(...)
end

function entity_query.any(...)
  return query_builder().any(...)
end

function entity_query.none(...)
  return query_builder().none(...)
end

function entity_query:has_valid_archetype(archetype)
  local archetype_cache = self._archetype_cache
  local cache_result = archetype_cache[archetype]

  if not (cache_result == nil) then
    return cache_result
  end

  local archetype_validity = true

  if #self._none_components > 0 and archetype:has_any(self._none_components) then
    archetype_validity = false
  end

  if #self._any_components > 0 and not archetype:has_any(self._any_components) then
    archetype_validity = false
  end

  if #self._all_components > 0 and not archetype:has_all(self._all_components) then
    archetype_validity = false
  end

  archetype_cache[archetype] = archetype_validity

  return archetype_validity
end

function entity_query:match(entity)
  if #self._none_filters > 0 then
    for _, filter in pairs(self._none_filters) do
      if filter(entity) then
        return false
      end
    end
  end

  if #self._any_filters > 0 then
    local has_any_filters = false

    for _, filter in pairs(self._any_filters) do
      if filter(entity) then
        has_any_filters = true
      end
    end

    if not has_any_filters then
      return false
    end
  end

  if #self._all_filters > 0 then
    for _, filter in pairs(self._all_filters) do
      if not filter(entity) then
        return false
      end
    end
  end

  return true
end

function entity_query.filter(filter_fn)
  return function(config)
    local filter = { is_filter = true }
    filter.__index = filter

    function filter.call(entity)
      return filter_fn(entity, config)
    end

    setmetatable(filter, { __call = function(f, entity) return f.call(entity) end })

    return filter
  end
end

return setmetatable(entity_query, {
  __call = function(eq, all, any, none) return eq.create(all, any, none) end,
})

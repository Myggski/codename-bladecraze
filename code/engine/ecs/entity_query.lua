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

-- TODO: Optimize this by check archetypes instead of every entity and cache what archetypes are ok and not for the query
-- TODO: Do some sort of archetype_changed event to make this match redo the check for the archetype
function entity_query:match(entity)
  if #self._none_components > 0 and entity:has_any_components(self._none_components) then
    return false
  end

  if #self._none_filters > 0 then
    for _, filter in pairs(self._none_filters) do
      if filter(entity) then
        return false
      end
    end
  end

  if #self._any_components > 0 and not entity:has_any_components(self._any_components) then
    return false
  end

  if #self._any_filters > 0 then
    local has_any_filters = false

    for _, filter in pairs(self._any_filters) do
      if filter(entity) then
        has_any_filters = true
      end
    end

    if not (has_any_filters == nil) then
      return false
    end
  end

  if #self._all_components > 0 and not entity:has_components(self._all_components) then
    return false
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

    local function check(entity)
      return filter_fn(entity, config)
    end

    return setmetatable(filter,
      {
        __index = filter,
        __call = function(_, entity) return check(entity) end
      })
  end
end

return setmetatable(entity_query, {
  __call = function(eq, all, any, none)
    return eq.create(all, any, none)
  end,
})

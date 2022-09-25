local entity_query = {}

local function seperate_query_type(list)
  local components, filters = {}, {}

  for item in list do
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

  all, all_filters = seperate_query_type(all)
  any, any_filters = seperate_query_type(any)
  none, none_filters = seperate_query_type(any)

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

function entity_query:match(entity)
  if self._none_components then

    if self._none_components and entity:has_components(self._none_components) then
      return false
    end

    if self._any_component and not entity:has_any_components(self._any_components) then
      return false
    end

    if self._all_components and not entity:has_components(self._all_components) then
      return false
    end

    return true
  end
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

setmetatable(entity_query, {
  __index = entity_query,
  __call = function(eq, all, any, none)
    return eq.create(all, any, none)
  end,
})

local entity_query = {}

function entity_query.create(all, any, none)
  return setmetatable({
    _any = any,
    _all = all,
    _none = none,
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

function entity_query.filter(filter_fn)
  return function(config)
    return {
      filter_fn = filter_fn,
      config = config
    }
  end
end

setmetatable(entity_query, {
  __index = entity_query,
  __call = function(t, all, any, none)
    return t.create(all, any, none)
  end,
})

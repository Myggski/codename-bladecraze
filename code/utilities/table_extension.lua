function table.index_of(table, value)
  for i, v in ipairs(table) do
    if v == value then
      return i
    end
  end
  return -1
end

function table.get_size(table)
  local count = 0
  for _, __ in pairs(table) do
    count = count + 1
  end
  return count
end

function table.contains_key(table, key)
  return not (table[key] == nil)
end

function table.pack_all(...) return { n = select('#', ...), ... } end

function table.unpack_all(t) return unpack(t, 1, t.n) end

function table.deep_clone(root_table, child_table)
  child_table = child_table or {}
  if root_table == nil then return nil end
  if child_table[root_table] then return child_table[root_table] end

  local clone_table = {}
  child_table[root_table] = clone_table
  setmetatable(clone_table, table.deep_clone(getmetatable(root_table), child_table))

  for key, value in next, root_table, nil do
    key = type(key) == "table" and table.deep_clone(root_table, child_table) or key
    value = type(value) == "table" and table.deep_clone(root_table, child_table) or value
    clone_table[key] = value
  end

  return clone_table
end

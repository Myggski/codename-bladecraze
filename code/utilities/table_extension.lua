function table.index_of(table, value)
  for i, v in ipairs(table) do
    if v == value then
      return i
    end
  end
  return nil
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

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

function table.deepcopy(o, seen)
  seen = seen or {}
  if o == nil then return nil end
  if seen[o] then return seen[o] end


  local no = {}
  seen[o] = no
  setmetatable(no, table.deepcopy(getmetatable(o), seen))

  for k, v in next, o, nil do
    k = (type(k) == 'table') and table.deepcopy(o, seen) or k
    v = (type(v) == 'table') and table.deepcopy(o, seen) or v
    no[k] = v
  end
  return no
end

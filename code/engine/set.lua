set = {}

function set.create(in_table)
  local res = {}
  for _, val in ipairs(in_table) do res[val] = true end
  return res
end

function set.union(set_a, set_b)
  local res = set.create {}
  for k in pairs(set_a) do res[k] = true end
  for k in pairs(set_b) do res[k] = true end
  return res
end

function set.add(in_set, key)
  in_set[key] = true
end

function set.intersection(set_a, set_b)
  local res = set.new {}
  for k in pairs(set_a) do
    res[k] = set_b[k]
  end
  return res
end

function set.delete(in_set, key)
  if set.contains(in_set, key) then
    in_set[key] = nil
  end
end

function set.tostring(in_set)
  local s = "{"
  local sep = ""
  for e in pairs(in_set) do
    s = s .. sep .. e
    sep = ", "
  end
  return s .. "}"
end

function set.get_length(in_set)
  local i = 0
  for index, value in pairs(in_set) do
    i = i + 1
  end
  return i
end

function set.get_first(in_set)
  return next(in_set)
end

function set.print(in_set)
  print(set.tostring(in_set))
end

function set.contains(in_set, key)
  return not (in_set[key] == nil)
end

return set

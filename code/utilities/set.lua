set = {}
    
function set.create(t)
  local res = {}
  for _, l in ipairs(t) do res[l] = true end
  return res
end

function set.union (set_a,set_b)
  local res = set.create{}
  for k in pairs(set_a) do res[k] = true end
  for k in pairs(set_b) do res[k] = true end
  return res
end

function set.add(in_set, key)
  in_set[key] = true
end

function set.intersection (set_a,set_b)
  local res = set.new{}
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

function set.tostring (in_set)
  local s = "{"
  local sep = ""
  for e in pairs(in_set) do
    s = s .. sep .. e
    sep = ", "
  end
  return s .. "}"
end

function set.print(in_set)
  print(set.tostring(in_set))
end

function set.contains(in_set, key)
  return in_set[key] ~= nil
end

return set

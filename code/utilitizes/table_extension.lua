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

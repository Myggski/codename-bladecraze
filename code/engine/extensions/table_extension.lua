-- Returns the index of a value in a table
function table.index_of(table, value)
  if not table then
    return -1
  end

  for i, v in ipairs(table) do
    if v == value then
      return i
    end
  end

  return -1
end

-- Returns the size of a table, when #table is not enough
function table.get_size(table)
  local count = 0
  for _, __ in pairs(table) do
    count = count + 1
  end
  return count
end

-- Checks if the table has a specific property value
function table.contains_key(table, key)
  return not (table[key] == nil)
end

function table.pack_all(...) return { n = select("#", ...), ... } end

function table.unpack_all(t) return unpack(t, 1, t.n) end

-- Deep clones tables, to make sure that a value doesn't refer the same table as another
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

function table.binary_search(t, x, low, high)
  if low > high then
    return -1
  else
    mid = math.floor((low + high) / 2)
    if x == t[mid] then
      return mid
    elseif x > t[mid] then --x is on the right side
      return table.binary_search(t, x, mid + 1, high)
    else -- x is on the left side
      return table.binary_search(t, x, low, mid - 1)
    end
  end
end

--add number tables with same keys together
function table.add_numeric(t1, t2)
  local result = {}
  for key, value in pairs(t2) do
    if t1[key] then
      result[key] = t1[key] + value
    end
  end
  return result
end

--adds numbers from t2 to t1 numbers without checks
function table.add_numeric_unsafe(t1, t2)
  for key, value in pairs(t2) do
    t1[key] = t1[key] + value
  end
end

--in-place fisher-yates shuffle
function table.shuffle(t)
  local size = #t
  local rand
  for i = size, 2, -1 do
    rand = love.math.random(1, i)
    t[i], t[rand] = t[rand], t[i]
  end
end

function table.insert_many(t, value, count)
  for i = 1, count do
    table.insert(t, value)
  end
end

--[[
   BINARY INSERTION SORT source: http://lua-users.org/wiki/BinaryInsert   
   
   "Inserts a given value through BinaryInsert into the table sorted by [, comp].
   
   If 'comp' is given, then it must be a function that receives
   two table elements, and returns true when the first is less
   than the second, e.g. comp = function(a, b) return a > b end,
   will give a sorted table, with the biggest value on position 1.
   [, comp] behaves as in table.sort(table, value [, comp])
   returns the index where 'value' was inserted"
]]
local comparison_func_default = function(a, b) return a < b end
function table.binary_insert(t, value, comparison_func)
  local start_position = 1
  local end_position = #t

  -- Initialise compare function
  local comparison_func = comparison_func or comparison_func_default
  --  Initialise numbers
  local mid_position, state = 1, 0
  -- Get insert position
  while start_position <= end_position do
    -- calculate middle
    mid_position = math.floor((start_position + end_position) / 2)
    -- compare
    if comparison_func(value, t[mid_position]) then
      end_position, state = mid_position - 1, 0
    else
      start_position, state = mid_position + 1, 1
    end
  end
  table.insert(t, (mid_position + state), value)
  return (mid_position + state)
end

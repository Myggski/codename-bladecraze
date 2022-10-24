-- Returns the distance between two points.
function math.dist(x1, y1, x2, y2) return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5 end

-- Clamps a number to within a certain range.
function math.clamp(low, n, high) return math.min(math.max(low, n), high) end

function math.clamp01(n) return math.min(math.max(0, n), 1) end

-- Linear interpolation between two numbers.
function math.lerp(a, b, t) return (1 - t) * a + t * b end

function math.lerp2(a, b, t) return a + (b - a) * t end

-- Normalize two numbers.
function math.normalize(x, y) local l = (x * x + y * y) ^ .5 if l == 0 then return 0, 0, 0 else return x / l, y / l, l end end

function math.normalize2(vector)
  local l = (vector.x * vector.x + vector.y * vector.y) ^ .5
  if l == 0 then
    return { x = 0, y = 0 }
  else
    return { x = vector.x / l, y = vector.y / l }
  end
end

-- Returns 'n' rounded to the nearest 'deci'th (defaulting whole numbers).
function math.round(n, deci) deci = 10 ^ (deci or 0) return math.floor(n * deci + .5) / deci end

-- Randomly returns either -1 or 1.
function math.rsign() return love.math.random(2) == 2 and 1 or -1 end

-- Returns 1 if number is positive, -1 if it's negative, or 0 if it's 0.
function math.sign(n) return n > 0 and 1 or n < 0 and -1 or 0 end

function math.average(t)
  local sum = 0

  for _, v in pairs(t) do -- Get the sum of all numbers in t
    sum = sum + v
  end
  return sum / #t
end

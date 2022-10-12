local level_generator = {}

local empty_tile = 'E'
local indestructible_tile = '0'
local destructible_tiles = { '1', '2', '3', '4' }

local function generate_level_data()
  local width, height, content = 17, 17, ""
  local max_tiles = width * height - 12
  local min_tile_count = math.floor(max_tiles * 0.8)
  local skippable_tile_count = max_tiles - min_tile_count
  local skipped_tiles = 0

  get_random_tile = function()
    if skipped_tiles < skippable_tile_count then
      local rand = love.math.random(10)
      --chance to make empty tile
      if rand == 1 then
        skipped_tiles = skipped_tiles + 1
        return empty_tile
      end
    end
    local rand_index = love.math.random(#destructible_tiles)
    return destructible_tiles[rand_index]
  end

  for row = 1, height do
    for col = 1, width do
      --empty corner tiles
      local tile = ""
      if row == 1 and (col <= 2 or col >= width - 1) or
          row == 2 and (col == 1 or col == width) or
          row == height - 1 and (col == 1 or col == width) or
          row == height and (col <= 2 or col >= width - 1)
      then
        tile = empty_tile
      else
        --borders shouldn't have indestructible tiles
        if row > 1 and row < height and col > 1 and col < width then
          if col % 2 == 0 and row % 2 == 0 then
            tile = indestructible_tile
            goto continue
          end
        end
        tile = get_random_tile()
      end
      ::continue::
      content = content .. tile
    end
  end
  return {
    width = width,
    height = height,
    content = content,
    empty_tile = empty_tile,
    indestructible_tile = indestructible_tile,
    destructible_tiles = destructible_tiles
  }
end

return { generate_level_data = generate_level_data }

local level_generator = {}

local empty_tile = 'E'
local indestructible_tile = '0'
local destructible_tiles = { '1', '2', '3' }
local player_tile = 'P'

local function generate_level_data()
  local width, height, content = GAME.OUTER_GRID_COL_COUNT, GAME.OUTER_GRID_ROW_COUNT, ""
  local max_tiles = GAME.INNER_GRID_COL_COUNT * GAME.INNER_GRID_ROW_COUNT - GAME.SPAWN_TILE_COUNT
  local max_percentage_skippable_tiles = 0.2
  local chance_of_empty = 0.1
  local skippable_tile_count = math.floor(max_percentage_skippable_tiles * max_tiles)
  local skipped_tiles = 0
  local outer_edges = { top = 1, bot = height, left = 2, right = width - 1 }
  local inner_edges = { top = 2, bot = height - 1, left = 3, right = width - 2 }

  local get_random_tile = function()
    if skipped_tiles < skippable_tile_count then
      local rand = love.math.random()
      if rand <= chance_of_empty then
        skipped_tiles = skipped_tiles + 1
        return empty_tile
      end
    end
    local rand_index = love.math.random(#destructible_tiles)
    return destructible_tiles[rand_index]
  end

  for row = 1, height do
    for col = 1, width do
      local tile = ""

      --indestructible borders
      if row == outer_edges.top or row == outer_edges.bot or col <= outer_edges.left or col >= outer_edges.right then
        tile = indestructible_tile
        goto continue
      end

      --empty v shape corner tiles
      if row == inner_edges.top and (col <= inner_edges.left + 1 or col >= inner_edges.right - 1) or
          row == inner_edges.top + 1 and (col == inner_edges.left or col == inner_edges.right) or
          row == inner_edges.bot and (col <= inner_edges.left + 1 or col >= inner_edges.right - 1) or
          row == inner_edges.bot - 1 and (col == inner_edges.left or col == inner_edges.right)
      then
        local is_corner = row == inner_edges.top and col == inner_edges.left or
            row == inner_edges.top and col == inner_edges.right or
            row == inner_edges.bot and col == inner_edges.left or
            row == inner_edges.bot and col == inner_edges.right
        if is_corner then
          tile = player_tile
        else
          tile = empty_tile
        end
      else
        --borders shouldn't have indestructible tiles
        if row > inner_edges.top and row < inner_edges.bot and col > inner_edges.left and col < inner_edges.right then
          if col % 2 == 0 and row % 2 == 1 then
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
    player_tile = player_tile,
    indestructible_tile = indestructible_tile,
    destructible_tiles = destructible_tiles,
  }
end

return { generate_level_data = generate_level_data }

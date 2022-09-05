GAME = {
  GRID_COL_COUNT = 16,
  GRID_ROW_COUNT = 9,
  GAME_WIDTH = 256,
  GAME_HEIGHT = 144,
  PROJECTILE_TYPES = {
    NONE = 0,
    ARROW = 1,
    BULLET = 2,
    MAGIC = 3,
  },
}
PLAYER = {
  ACTIONS = {
    NONE = 0,
    BASIC = 1,
    SPECIAL = 2,
    ULTIMATE = 3
  },
}
COLOR = {
  RED = { 1, 0, 0, 1 },
  BLUE = { 0, 0, 1, 1 },
  GREEN = { 0, 1, 0, 1 },
  CYAN = { 0, 1, 1, 1 },
  YELLOW = { 1, 1, 0, 1 },
  MAGENTA = { 1, 0, 1, 1 },
  WHITE = { 1, 1, 1, 1 },
  BLACK = { 0, 0, 0, 1 }
}
GAME.TILE_SIZE = GAME.GAME_WIDTH / GAME.GRID_COL_COUNT

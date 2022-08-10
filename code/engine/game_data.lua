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
GAME.TILE_SIZE = GAME.GAME_WIDTH / GAME.GRID_COL_COUNT

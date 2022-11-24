-- stats = {
--   available_bombs = 0,
--   bomb_radius = 1,
--   explosion_duration = 0,
--   max_bombs = 0,
--   bomb_spawn_delay = 0
-- }

local UPGRADE_KEYS = {
  BOMBS = "available_bombs",
  BOMB_RADIUS = "bomb_radius",
  SPEED = "speed",
}

local data = {
  {
    name = "fire_upgrade",
    animation_data = {0, 0, 16, 24, 1},
    stats = {
      [UPGRADE_KEYS.BOMB_RADIUS] = 1,
    }
  },
  {
    name = "bomb_upgrade",
    animation_data = {0, 24, 16, 24, 1},
    stats = {
      [UPGRADE_KEYS.BOMBS] = 1,
    }
  },
  {
    name = "speed_upgrade",
    animation_data = {0, 48, 16, 24, 1},
    stats = {
      [UPGRADE_KEYS.SPEED] = 10
    }
  }
}

return {
  UPGRADE_KEYS = UPGRADE_KEYS,
  data = data
}

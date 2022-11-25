local data = {
  {
    name = "fire_upgrade",
    animation_data = { 0, 0, 16, 16, 1 },
    stats = {
      [UPGRADE_KEYS.BOMB_RADIUS] = 1,
    }
  },
  {
    name = "bomb_upgrade",
    animation_data = { 0, 16, 16, 16, 1 },
    stats = {
      [UPGRADE_KEYS.BOMBS] = 1,
    }
  },
  {
    name = "speed_upgrade",
    animation_data = { 0, 32, 16, 16, 1 },
    stats = {
      [UPGRADE_KEYS.SPEED] = 10
    }
  }
}

return data

local character_data = {
  elf = {
    name = "Elven Ranger",
    stats = {
      strength = 0,
      intelligence = 0,
      agility = 2
    },
    idle_animation = { 128, 36, 16, 28, 4 },
    run_animation = { 192, 36, 16, 28, 4 },
    hit_animation = { 256, 36, 16, 28, 1 },
    projectile_type = GAME.PROJECTILE_TYPES.ARROW,
  },
  knight = {
    name = "The Tank",
    stats = {
      strength = 2,
      intelligence = 0,
      agility = 0
    },
    idle_animation = { 128, 68, 16, 28, 4 },
    run_animation = { 192, 68, 16, 28, 4 },
    hit_animation = { 256, 68, 16, 28, 1 },
  },
  lizard = {
    name = "Dragon",
    stats = {
      strength = 1,
      intelligence = 0,
      agility = 1
    },
    idle_animation = { 128, 228, 16, 28, 4 },
    run_animation = { 192, 228, 16, 28, 4 },
    hit_animation = { 256, 228, 16, 28, 1 },
    projectile_type = GAME.PROJECTILE_TYPES.BULLET,
  },
  wizard = {
    name = "Arcanist",
    stats = {
      strength = 0,
      intelligence = 2,
      agility = 0
    },
    idle_animation = { 128, 164, 16, 28, 4 },
    run_animation = { 192, 164, 16, 28, 4 },
    hit_animation = { 256, 164, 16, 28, 1 },
    projectile_type = GAME.PROJECTILE_TYPES.MAGIC,
  },
}

return character_data

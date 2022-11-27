local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local powerup = require "code.game.entities.powerups.powerup"
local powerup_data = require "code.game.entities.powerups.powerup_data"

local dead_query = entity_query.all(
  components.animation,
  components.box_collider,
  components.health,
  components.position,
  components.size
).none(components.input, components.damager, components.explosion_radius)

local powerup_spawner_system = system(dead_query, function(self, dt)
  local powerup_table = self.powerup_table
  local data
  self:for_each(function(entity)
    if entity:is_alive() then
      goto continue
    end

    data = table.remove(powerup_table) --pop last element
    if data == -1 or data == nil then
      goto continue
    end

    powerup.create(self:get_world(), entity[components.position], data)

    ::continue::
  end)
end)

function powerup_spawner_system:on_start()
  local powerup_table = {}
  local size = GAME.INNER_GRID_COL_COUNT * GAME.INNER_GRID_ROW_COUNT - GAME.SPAWN_TILE_COUNT
  local count, powerup_data_count = 0, 0
  local empty_padding = 1.5
  --add padding for empty tiles, ie. datacount = 3, empty_padding == 2, powerup chance is 3/5
  local powerup_data_count = #powerup_data + empty_padding


  count = math.ceil(size / powerup_data_count)
  for i = 1, #powerup_data do
    table.insert_many(powerup_table, powerup_data[i], count)
  end

  table.insert_many(powerup_table, -1, count * empty_padding)
  table.shuffle(powerup_table)
  assert(#powerup_table >= size)
  self.powerup_table = powerup_table
end

return powerup_spawner_system

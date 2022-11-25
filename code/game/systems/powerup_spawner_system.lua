local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local wall = require "code.game.entities.walls.destructible_wall"
local powerup = require "code.game.entities.powerups.powerup"
local powerup_data = require "code.game.entities.powerups.powerup_data"


local dead_query = entity_query.all(components.health, components.box_collider)
powerup_data = powerup_data.data

local powerup_spawner_system = system(dead_query, function(self, dt)
  local powerup_table = self.powerup_table
  local data
  self:for_each(function(entity)
    if (entity:is_alive()) then
      goto continue
    end

    data = table.remove(powerup_table) --pop last element
    if data == -1 or data == nil then
      goto continue
    end

    powerup.create(self:get_world(), entity[components.position], data)

    ::continue::
  end, wall:get_archetype())
end)

function powerup_spawner_system:on_start()
  local powerup_table = {}
  local size, count, powerup_data_count = 128, 0, 0
  local powerup_data_count = #powerup_data
  if math.is_odd(powerup_data_count) then --check odd and add padding
    powerup_data_count = powerup_data_count + 1
  end

  count = math.floor(size / powerup_data_count)
  for i = 1, #powerup_data do
    table.insert_many(powerup_table, powerup_data[i], count)
  end

  table.insert_many(powerup_table, -1, count)
  table.shuffle(powerup_table)
  self.powerup_table = powerup_table
end

return powerup_spawner_system

local bomb = require "code.game.entities.bomb"
local components = require "code.engine.components"
local function_manager = require "code.engine.function_manager"
local player = require "code.game.entities.player"
local system = require "code.engine.ecs.system"
local collision = require "code.engine.collision"
local vector2 = require "code.engine.vector2"

local BOMB_SIZE = vector2.one()

local attack_player_system = system(function(self)
  local position, bomb_spawn_position, input, player_stats, box_collider, size, has_collision = nil, nil, nil, nil, nil,
      nil, false

  self:for_each(function(entity)
    input = entity[components.input]
    player_stats = entity[components.player_stats]
    position = entity[components.position]
    size = entity[components.size]
    box_collider = entity[components.box_collider]
    bomb_spawn_position = vector2(
      math.round(position.x + size.x - box_collider.size.x),
      math.round(position.y + size.y - box_collider.size.y)
    )

    if input.action == PLAYER.ACTIONS.BASIC and player_stats.available_bombs > 0 then
      local found_entities = self:find_at(bomb_spawn_position, BOMB_SIZE, set.create { entity })
      local found_position, found_box_collider = nil, nil

      for found_entity, _ in pairs(found_entities) do
        found_box_collider = found_entity[components.box_collider]

        if not (found_box_collider and found_box_collider.enabled) then
          goto no_bomb
        end

        found_position = collision.get_collider_position(found_entity[components.position], found_box_collider)

        if collision.overlap(bomb_spawn_position, BOMB_SIZE, found_position, found_box_collider.size) then
          goto no_bomb
        end
      end

      player_stats.available_bombs = player_stats.available_bombs - 1
      bomb.create(self:get_world(), bomb_spawn_position, player_stats)

      ::no_bomb::
    end
  end, player.get_archetype())
end)

return attack_player_system

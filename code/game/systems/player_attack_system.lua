local bomb = require "code.game.entities.bomb"
local components = require "code.engine.components"
local function_manager = require "code.engine.function_manager"
local player = require "code.game.entities.player"
local system = require "code.engine.ecs.system"
local utilities = require "code.engine.utilities"
local vector2 = require "code.engine.vector2"

local BOMB_SIZE = vector2.one()

local function destroy_bomb(bomb_entity, player_stats)
  player_stats.available_bombs = player_stats.available_bombs + 1
  bomb_entity:destroy()
end

local function spawn_bomb(world, position, player_stats)
  local bomb_entity = bomb.create(world, position)
  player_stats.available_bombs = player_stats.available_bombs - 1
  function_manager.execute_after_seconds(destroy_bomb, player_stats.explosion_duration, bomb_entity, player_stats)
end

local attack_player_system = system(function(self)
  local position, bomb_spawn_position, input, player_stats, box_collider, has_collision = nil, nil, nil, nil, nil, false

  self:for_each(function(entity)
    input = entity[components.input]
    player_stats = entity[components.player_stats]
    position = entity[components.position]
    bomb_spawn_position = vector2(math.floor(position.x + (BOMB_SIZE.x * 0.5)),
      math.floor(position.y + (BOMB_SIZE.y * 0.5)))

    if input.action == PLAYER.ACTIONS.BASIC and player_stats.available_bombs > 0 then
      local found_entities = self:find_at(bomb_spawn_position, BOMB_SIZE, set.create { entity })

      for found_entity, _ in pairs(found_entities) do
        box_collider = found_entity[components.box_collider]
        has_collision = box_collider and box_collider.enabled
        if has_collision and utilities.overlap(position, BOMB_SIZE, box_collider.position, box_collider.size) then
          goto no_bomb
        end
      end

      spawn_bomb(self:get_world(), bomb_spawn_position, player_stats)

      ::no_bomb::
    end
  end, player.get_archetype())
end)

return attack_player_system

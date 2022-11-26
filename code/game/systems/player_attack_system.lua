local bomb = require "code.game.entities.bomb"
local components = require "code.engine.components"
local player = require "code.game.entities.player"
local system = require "code.engine.ecs.system"
local collision = require "code.engine.collision"
local vector2 = require "code.engine.vector2"
local audio = require "code.engine.audio"

local BOMB_SIZE = vector2.one()

local attack_player_system = system(function(self, dt)
  local position, bomb_spawn_position, input, player_stats, box_collider, size, has_collision = nil, nil, nil, nil, nil,
      nil, false
  local is_attacker, can_collide = false, false
  local other_entity

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

    -- Handle bomb delay
    if self.bombers_on_delay[player_stats] and self.bombers_on_delay[player_stats] > 0 then
      self.bombers_on_delay[player_stats] = self.bombers_on_delay[player_stats] - dt

      if self.bombers_on_delay[player_stats] <= 0 then
        self.bombers_on_delay[player_stats] = 0
      end
    end

    -- Check for attack
    if input.action == PLAYER.ACTIONS.BASIC and player_stats.available_bombs > 0 then
      local other_entities = self:find_at(bomb_spawn_position, BOMB_SIZE, set.create { entity })
      local other_position, other_box_collider = nil, nil

      -- Check for entities in the bomb spawning position
      for i = 1, #other_entities do
        other_entity = other_entities[i]
        is_attacker = other_entity.archetype == entity.archetype
        other_box_collider = other_entity[components.box_collider]
        can_collide = other_box_collider and other_box_collider.enabled

        -- If there's something that can collide and is not another attacker, check overlapping
        if not is_attacker and can_collide then
          other_position = collision.get_collider_position(other_entity[components.position], other_box_collider)
          if collision.overlap(bomb_spawn_position, BOMB_SIZE, other_position, other_box_collider.size) then
            goto no_bomb
          end
        end
      end

      -- If no delay active, drop bomb
      if not self.bombers_on_delay[player_stats] or self.bombers_on_delay[player_stats] == 0 then
        audio:play("drop_bomb.wav", love.math.random(80, 120) / 100)
        player_stats.available_bombs = player_stats.available_bombs - 1
        bomb.create(self:get_world(), bomb_spawn_position, player_stats)
        self.bombers_on_delay[player_stats] = player_stats.bomb_spawn_delay
      end

      ::no_bomb::
    end
  end, player.get_archetype())
end)

function attack_player_system:on_start()
  self.bombers_on_delay = {}
end

return attack_player_system

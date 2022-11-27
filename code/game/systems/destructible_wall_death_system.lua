local components = require "code.engine.components"
local entity_query = require "code.engine.ecs.entity_query"
local system = require "code.engine.ecs.system"
local dissolve_shader = require "code.game.shaders.dissolve"
local fire = require "code.game.entities.fire"
local asset_manager = require "code.engine.asset_manager"
local vector2 = require "code.engine.vector2"

-- Adds wall for "shader animation"
local function add_dead_wall(self, shader, destroy_timer)
  table.insert(self.dead_walls,
    {
      shader = shader,
      data = {
        current_time = 0,
        duration = destroy_timer
      }
    }
  )
end

-- Set shader values for current dead wall
local function set_shader(shader, data)
  shader:send("noise_texture", asset_manager:get_image("noise.png"))
  shader:send("dissolve_value", data.current_time / data.duration)
  data.current_time = data.current_time + love.timer.getDelta()
end

local wall_death_query = entity_query.all(
  components.animation,
  components.box_collider,
  components.health,
  components.position,
  components.size
).none(components.input)

local player_death_system = system(wall_death_query, function(self, dt)
  local position, health, shader, destroy_timer, dead_wall = nil, nil, nil, nil, nil

  self:for_each(function(entity)
    health = entity[components.health]
    shader = entity[components.shader]
    destroy_timer = entity[components.destroy_timer]

    if health <= 0 and not shader then
      position = entity[components.position]
      shader = love.graphics:newShader(dissolve_shader)
      entity[components.shader] = shader

      local found_entities = self:find_at(position, vector2.one(), set.create({ entity }))

      for index = #found_entities, 1, -1 do
        if found_entities[index].archetype == fire.get_archetype() then
          found_entities[index]:destroy()
        end
      end

      add_dead_wall(self, shader, destroy_timer)
    end
  end)

  for index = #self.dead_walls, 1, -1 do
    dead_wall = self.dead_walls[index]

    set_shader(dead_wall.shader, dead_wall.data)
  end
end)

function player_death_system:on_start()
  self.dead_walls = {}
end

function player_death_system:on_destroy()
  self.dead_walls = nil
end

return player_death_system

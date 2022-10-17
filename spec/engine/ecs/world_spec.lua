insulate("world", function()
  require "spec.love_setup"
  local world = require "code.engine.ecs.world"
  local system = require "code.engine.ecs.system"

  local level_one

  before_each(function()
    level_one = world()
  end)

  after_each(function()
    level_one:destroy()
    level_one = nil
  end)

  describe("entity", function()
    it("should create an entity and group it to a the right archetype", function()
      local new_entity = level_one:entity()

      assert.is_not_equal(level_one._entity_data[1].entities[1], nil)
      assert.is_equal(level_one._entity_data[1].entities[1], new_entity)
    end)

    it("should reuse an id of a destroyed entity when created", function()
      local new_entity = level_one:entity()

      assert.is_truthy(new_entity:get_id() == 1)

      level_one:destroy()
      local another_entity = level_one:entity()

      assert.is_truthy(new_entity:get_id() == -1)
      assert.is_truthy(another_entity:get_id() == 1)
    end)
  end)

  describe("destroy", function()
    it("should remove att systems and entities from the world but keeps the archetypes", function()
      local new_entity = level_one:entity()
      local entity_archetype = new_entity.archetype
      level_one:add_system(system())

      assert.is_truthy(table.get_size(level_one._entity_data) == 1)
      assert.is_truthy(table.get_size(level_one._entity_data[1].entities) == 1)
      assert.is_truthy(table.get_size(level_one._systems) == 1)

      level_one:destroy()

      assert.is_truthy(table.get_size(level_one._entity_data) == 1)
      assert.is_truthy(table.get_size(level_one._entity_data[1].entities) == 0)
      assert.is_falsy(level_one._entity_data[1] == nil)
      assert.is_truthy(table.get_size(level_one._systems) == 0)
    end)
  end)

  describe("update", function()
    it("should call the systems in the same order as they have been added", function()
      local value = 0

      local first_system = system(_, function(self, dt)
        value = value + 10
      end)

      local second_system = system(_, function(self, dt)
        value = value * 0.5
      end)

      local third_system = system(_, function(self, dt)
        value = value - 10
      end)

      level_one:add_system(first_system) -- called first
      level_one:add_system(second_system) -- caled second
      level_one:add_system(third_system) -- called third
      level_one:update()

      assert.is_truthy(value == -5)
    end)
  end)
end)

insulate("world", function()
  require "spec.love_setup"
  local world = require "code.engine.ecs.world"
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

      assert.is_not_equal(level_one._entities[new_entity.archetype][new_entity:get_id()], nil)
      assert.is_equal(level_one._entities[new_entity.archetype][new_entity:get_id()], new_entity)
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
end)

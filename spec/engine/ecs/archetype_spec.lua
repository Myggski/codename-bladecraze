insulate("archetype", function()
  require "spec.love_setup"
  local component = require "code.engine.ecs.component"
  local archetype = require "code.engine.ecs.archetype"

  local position_component = component()
  local acceleration_component = component()

  describe("modify", function()
    it("should create a unique archetype if componets differ", function()
      local version = archetype.get_version()
      local archetype_a = archetype.setup(position_component, acceleration_component)
      local archetype_b = archetype.setup(position_component)
      local archetype_c = archetype.setup(position_component, acceleration_component)
      local archetype_d = archetype.setup(acceleration_component, position_component) -- Order doesn't matter

      assert.is_not_nil(archetype_a)
      assert.is_truthy(archetype_a:has(position_component))
      assert.is_truthy(archetype_a:has(acceleration_component))

      assert.is_not_nil(archetype_b)
      assert.is_truthy(archetype_b:has(position_component))
      assert.is_falsy(archetype_b:has(acceleration_component))

      assert.is_equal(archetype_a, archetype_c)
      assert.is_not_equal(archetype_b, archetype_c)
      assert.is_not_equal(archetype_b, archetype_a)
      assert.is_equal(archetype_a, archetype_d)
      assert.is_not_equal(archetype_b, archetype_d)

      assert.is_not_same(version, archetype.get_version())
    end)
  end)

  describe("add", function()
    it("should create same archetype but with additional component", function()
      local archetype_a = archetype.setup(position_component)
      local archetype_b = archetype.setup(position_component, acceleration_component)
      local archetype_c = archetype_a:add(acceleration_component)

      assert.is_falsy(archetype_a:has(acceleration_component))
      assert.is_truthy(archetype_b:has(acceleration_component))
      assert.is_not_equal(archetype_a, archetype_c)
      assert.is_equal(archetype_b, archetype_c)
      assert.is_same(archetype_b:get_version(), archetype_c:get_version())
    end)
  end)

  describe("remove", function()
    it("should create same archetype but with one less component", function()
      local archetype_a = archetype.setup(position_component)
      local archetype_b = archetype.setup(position_component, acceleration_component)
      local archetype_c = archetype_b:remove(acceleration_component)

      assert.is_falsy(archetype_a:has(acceleration_component))
      assert.is_truthy(archetype_b:has(acceleration_component))
      assert.is_not_equal(archetype_b, archetype_c)
      assert.is_equal(archetype_a, archetype_c)
    end)
  end)
end)

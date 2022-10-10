insulate("component", function()
  require "spec.love_setup"
  local component = require "code.engine.ecs.component"

  describe("get_type", function()
    it("should return component type", function()
      local first_component = component()
      local second_component = component()
      local third_component = component()

      local first_value = first_component()
      local second_value = second_component()
      local third_value = third_component()

      assert.is_equals(first_value:get_type(), first_component)
      assert.is_equals(second_value:get_type(), second_component)
      assert.is_equals(third_value:get_type(), third_component)
      assert.are_not.is_equals(first_value:get_type(), third_component)
      assert.are_not.is_equals(second_value:get_type(), first_component)
      assert.are_not.is_equals(third_value:get_type(), second_component)
    end)
  end)

  describe("is", function()
    it("should return true if the parameter value is the same component type", function()
      local first_component = component()
      local second_component = component()
      local third_component = component()

      local first_value = first_component()
      local second_value = second_component()
      local third_value = third_component()

      assert.is_truthy(first_value:is(first_component))
      assert.is_truthy(second_value:is(second_component))
      assert.is_truthy(third_value:is(third_component))
    end)

    it("should return false if the parameter value is not the same component type", function()
      local first_component = component()
      local second_component = component()
      local third_component = component()

      local first_value = first_component()
      local second_value = second_component()
      local third_value = third_component()

      assert.is_falsy(first_value:is(third_value))
      assert.is_falsy(second_value:is(first_value))
      assert.is_falsy(third_value:is(second_value))
    end)
  end)

  describe("when the component type has default value set", function()
    describe("and the default value is a table", function()
      describe("and the component itself has no value set", function()
        it("should deep clone the value from the component type", function()
          local first_component = component({ a = 1, b = 2 })
          local first_value = first_component()

          assert.are.same(first_component.value, first_value.value)
          assert.are_not.equal(first_component.value, first_value.value)
        end)
      end)

      describe("and the component itself has its own value set", function()
        it("should override the default value, but not deep clone", function()
          local first_value_table = { c = 3, d = 4 }
          local first_component = component({ a = 1, b = 2 })
          local first_value = first_component(first_value_table)

          assert.are.same(first_value_table, first_value.value)
          assert.are.equal(first_value_table, first_value.value)
          assert.are_not.same(first_component.value, first_value.value)
          assert.are_not.equal(first_component.value, first_value.value)
        end)
      end)
    end)

    describe("and the default value is not a table", function()
      describe("and the component itself has no value set", function()
        it("should set value the same as default value", function()
          local first_component = component("I am a string")
          local first_value = first_component()

          assert.are.same(first_component.value, first_value.value)
          assert.are.equal(first_component.value, first_value.value)
        end)
      end)

      describe("and the component itself has its own value set", function()
        it("should override the default value, but not deep clone", function()
          local first_value_string = "I am a unique string"
          local first_component = component("I am a string")
          local first_value = first_component(first_value_string)

          assert.are.same(first_value_string, first_value.value)
          assert.are.equal(first_value_string, first_value.value)
          assert.are_not.same(first_component.value, first_value.value)
          assert.are_not.equal(first_component.value, first_value.value)
        end)
      end)
    end)
  end)
end)

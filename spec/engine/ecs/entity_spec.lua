insulate("entity", function()
  require "spec.love_setup"

  local entity = require "code.engine.ecs.entity"
  local component = require "code.engine.ecs.component"

  local is_alive_callback = function() end
  local destroy_callback = function() end

  local first_entity
  local second_entity

  local health_component
  local position_component
  local acceleration_component

  before_each(function()
    first_entity = entity(1, is_alive_callback, destroy_callback)
    second_entity = entity(2, is_alive_callback, destroy_callback)

    health_component = component()
    position_component = component()
    acceleration_component = component()
  end)

  after_each(function()
    first_entity = nil
    second_entity = nil

    health_component = nil
    position_component = nil
  end)

  describe("add_component", function()
    it("should add the components to the component list", function()
      first_entity:add_component(health_component, 100)
      second_entity[health_component] = 80

      assert.are.same(first_entity._component_values[health_component].value, 100)
      assert.are.same(second_entity._component_values[health_component].value, 80)
    end)
  end)

  describe("remove_component", function()
    it("should remove the components from the component list", function()
      first_entity:add_component(health_component, 100)
      second_entity[health_component] = 80

      assert.are.same(first_entity._component_values[health_component].value, 100)
      assert.are.same(second_entity._component_values[health_component].value, 80)

      first_entity:remove_component(health_component)
      second_entity[health_component] = nil

      assert.is_truthy(first_entity._component_values[health_component] == nil)
      assert.is_truthy(second_entity._component_values[health_component] == nil)
    end)
  end)

  describe("has_component", function()
    it("should return true when entity has the component", function()
      first_entity:add_component(health_component, 100)
      second_entity[health_component] = 80

      assert.is_truthy(first_entity:has_component(health_component))
      assert.is_truthy(second_entity:has_component(health_component))
    end)

    it("should return false when entity does not has the component", function()
      first_entity:add_component(health_component, 100)
      second_entity[health_component] = 80

      assert.is_falsy(first_entity:has_component(position_component))
      assert.is_falsy(second_entity:has_component(position_component))
    end)
  end)

  describe("has_components", function()
    it("should return true when entity has all the components", function()
      first_entity:add_component(health_component, 100)
      first_entity:add_component(position_component, { x = 0, y = 0 })
      second_entity[health_component] = 80
      second_entity[position_component] = { x = 0, y = 0 }

      assert.is_truthy(first_entity:has_components(health_component, position_component))
      assert.is_truthy(second_entity:has_component(health_component, position_component))
    end)

    it("should return false when entity only has one of the components", function()
      first_entity:add_component(health_component, 100)
      second_entity[health_component] = 80

      assert.is_falsy(first_entity:has_components(health_component, position_component))
      assert.is_falsy(second_entity:has_components(health_component, position_component))
    end)

    it("should return false when entity has no components set", function()
      assert.is_falsy(first_entity:has_components(health_component))
      assert.is_falsy(first_entity:has_components(position_component))
      assert.is_falsy(first_entity:has_components(health_component, position_component))
      assert.is_falsy(second_entity:has_components(health_component))
      assert.is_falsy(second_entity:has_components(position_component))
      assert.is_falsy(second_entity:has_components(health_component, position_component))
    end)
  end)

  describe("has_any_components", function()
    it("should return true when entity has at least one of the components", function()
      first_entity:add_component(health_component, 100)
      second_entity[position_component] = { x = 0, y = 0 }

      assert.is_truthy(first_entity:has_any_components(health_component, position_component))
      assert.is_truthy(second_entity:has_any_components(health_component, position_component))
    end)

    it("should return false when entity has not any of the components", function()
      first_entity:add_component(acceleration_component, 10)
      second_entity[acceleration_component] = 2

      assert.is_falsy(first_entity:has_any_components(health_component, position_component))
      assert.is_falsy(second_entity:has_any_components(health_component, position_component))
    end)
  end)

  describe("get_id", function()
    it("should return the id of the entity", function()
      assert.are.same(first_entity:get_id(), 1)
      assert.are.same(second_entity:get_id(), 2)
    end)
  end)


  describe("is_alive", function()
    it("should call is_alive_callback", function()
      local is_alive_spy = spy.new(function() end)
      local destroy_spy = spy.new(function() end)
      local e = entity(3, is_alive_spy, destroy_spy)

      e:is_alive()

      assert.stub(is_alive_spy).was.called()
      assert.stub(destroy_spy).was_not_called()
    end)
  end)

  describe("destroy", function()
    it("should call destroy_callback", function()
      local is_alive_spy = spy.new(function() end)
      local destroy_spy = spy.new(function() end)
      local e = entity(3, is_alive_spy, destroy_spy)

      e:destroy()

      assert.stub(is_alive_spy).was_not_called()
      assert.stub(destroy_spy).was.called()
    end)
  end)
end)

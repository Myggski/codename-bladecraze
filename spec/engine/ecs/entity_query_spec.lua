insulate("entity_query", function()
  require "spec.love_setup"

  local component = require "code.engine.ecs.component"
  local entity = require "code.engine.ecs.entity"
  local entity_query = require "code.engine.ecs.entity_query"

  local health_component = component(0)
  local name_component = component("")
  local position_component = component({})

  local empty_func = function() end

  local first_entity = entity.create(1, empty_func, empty_func, health_component, name_component)
  local second_entity = entity.create(2, empty_func, empty_func, health_component)
  local third_entity = entity.create(3, empty_func, empty_func, name_component, position_component)
  local fourth_entity = entity.create(4, empty_func, empty_func, position_component)

  local health_filter = entity_query.filter(function(e, config)
    return e[health_component] >= config.min_health and e[health_component] <= config.max_health
  end)

  local is_healthy_filter = health_filter({
    min_health = 51,
    max_health = 100,
  })

  local is_wounded_filter = health_filter({
    min_health = 1,
    max_health = 50,
  })

  -- Entity 1 setup
  first_entity[health_component] = health_component(100)
  first_entity[name_component] = name_component("First Entity Second Component")

  -- Entity 2 setup
  second_entity[health_component] = health_component(50)

  -- Entity 3 setup
  third_entity[name_component] = name_component("Third Entity Second Component")
  third_entity[position_component] = position_component({ x = 18, y = 24 })

  -- Entity 4 setup
  fourth_entity[position_component] = position_component({ x = 6, y = 12 })

  describe("has_valid_archetype", function()
    describe("all", function()
      it("should only match with first_entity that has health and name component", function()
        local only_health_and_name = entity_query:all(health_component, name_component).build()

        assert.is_truthy(only_health_and_name:has_valid_archetype(first_entity.archetype))
        assert.is_falsy(only_health_and_name:has_valid_archetype(second_entity.archetype))
        assert.is_falsy(only_health_and_name:has_valid_archetype(third_entity.archetype))
        assert.is_falsy(only_health_and_name:has_valid_archetype(fourth_entity.archetype))
      end)
    end)

    describe("any", function()
      it("should match with first, second and third entity that has health or name component", function()
        local health_or_name = entity_query:any(health_component, name_component).build()

        assert.is_truthy(health_or_name:has_valid_archetype(first_entity.archetype))
        assert.is_truthy(health_or_name:has_valid_archetype(second_entity.archetype))
        assert.is_truthy(health_or_name:has_valid_archetype(third_entity.archetype))
        assert.is_falsy(health_or_name:has_valid_archetype(fourth_entity.archetype))
      end)
    end)

    describe("none", function()
      it("should match with first and second entity that does not have position component", function()
        local not_position = entity_query:none(position_component).build()

        assert.is_truthy(not_position:has_valid_archetype(first_entity.archetype))
        assert.is_truthy(not_position:has_valid_archetype(second_entity.archetype))
        assert.is_falsy(not_position:has_valid_archetype(third_entity.archetype))
        assert.is_falsy(not_position:has_valid_archetype(fourth_entity.archetype))
      end)
    end)
  end)

  describe("match", function()
    describe("all", function()
      it("should only match with wounded entites", function()
        local only_wounded = entity_query:all(health_component, is_wounded_filter).build()

        assert.is_falsy(only_wounded:match(first_entity))
        assert.is_truthy(only_wounded:match(second_entity))
      end)
    end)

    describe("any", function()
      it("should match with both wounded and healthy entites", function()
        local wounded_or_healthy = entity_query:all(health_component):any(is_healthy_filter, is_wounded_filter).build()

        assert.is_truthy(wounded_or_healthy:match(first_entity))
        assert.is_truthy(wounded_or_healthy:match(second_entity))
      end)
    end)

    describe("none", function()
      it("should not match with wounded entites", function()
        local not_wounded = entity_query:all(health_component):none(is_wounded_filter).build()

        assert.is_truthy(not_wounded:match(first_entity))
        assert.is_falsy(not_wounded:match(second_entity))
      end)
    end)
  end)
end)

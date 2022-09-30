insulate("system", function()
  require "spec.love_setup"

  local system = require "code.engine.ecs.system"
  local world = require "code.engine.ecs.world"
  local level_one = world();

  before_each(function()
    level_one = world()
  end)

  after_each(function()
    level_one:destroy()
  end)

  describe("get_type", function()
    describe("when system has been created", function()
      it("should return a unique id id of the system", function()
        local move_system = system()
        local shoot_system = system()

        local roleplaying_walk = move_system(level_one)
        local spray_and_pray = shoot_system(level_one)

        assert.is_equals(roleplaying_walk:get_type(), move_system)
        assert.is_equals(spray_and_pray:get_type(), shoot_system)
      end)
    end)
  end)

  describe("destroy", function()
    describe("when system has been destroyed", function()
      it("should be an empty table", function()
        local move_system = system()

        level_one:add_system(move_system)
        local roleplaying_walk = level_one._systems[move_system]

        assert.is_not_equal(level_one._systems[move_system], nil)
        assert.is_not_same(roleplaying_walk, {})

        roleplaying_walk:destroy()

        assert.is_equal(level_one._systems[move_system], nil)
        assert.is_same(roleplaying_walk, {})
      end)
    end)
  end)

  describe("update", function()
    describe("when a system is created with a update function", function()
      it("should set its update function properly", function()
        local update_spy = spy.new(function() end)
        local move_system = system(nil, update_spy)

        level_one:add_system(move_system)
        local roleplaying_walk = level_one._systems[move_system]

        roleplaying_walk:update()

        assert.stub(update_spy).was.called()
      end)
    end)
  end)
end)

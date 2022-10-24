

insulate("camera", function()
  require "spec.love_setup"
  local camera = require "code.engine.camera.camera"
  local vector2 = require "code.engine.vector2"
  local world_grid = require "code.engine.world_grid"

  local ZOOM_MAX = -3
  local ZOOM_MIN = 0
  
  local default_scale = camera.scale
  local default_zoom = camera.zoom

  before_each(function()
    stub(love.graphics, "getWidth").returns(1280)
    stub(love.graphics, "getHeight").returns(720)
  end)

  after_each(function()
    camera.scale = default_scale
    camera.zoom = default_zoom
    camera.is_fullscreen = false
    camera:look_at(0, 0)
  end)

  describe("get_screen_game_size", function()
    describe("when scale has default value (5)", function()
      describe("and zoom is set to zero", function()
        it("should return 1280 and 720 divided by five", function()
          local w, h = camera:get_screen_game_size()

          assert.is.truthy(w == 256)
          assert.is.truthy(h == 144)
        end)
      end)

      describe("and zoom is set to minus one", function()
        it("should return 1280 and 720 divided by four", function()
          camera:set_zoom(-1)
          local w, h = camera:get_screen_game_size()

          assert.is.truthy(w == 320)
          assert.is.truthy(h == 180)
        end)
      end)
    end)
  end)

  describe("get_screen_game_half_size", function()
    local get_screen_game_size_spy = nil

    before_each(function()
      get_screen_game_size_spy = spy.on(camera, "get_screen_game_size")
    end)

    describe("when scale has default value (5)", function()
      describe("and zoom is set to zero", function()
        it("should return 640 and 360 divided by five", function()
          local w, h = camera:get_screen_game_half_size()

          assert.spy(get_screen_game_size_spy).was.called()
          assert.is.truthy(w == 128)
          assert.is.truthy(h == 72)
        end)
      end)

      describe("and zoom is set to minus one", function()
        it("should return 640 and 360 divided by four", function()
          camera:set_zoom(-1)
          local w, h = camera:get_screen_game_half_size()

          assert.spy(get_screen_game_size_spy).was.called()
          assert.is.truthy(w == 160)
          assert.is.truthy(h == 90)
        end)
      end)
    end)
  end)

  describe("get_zoom_aspect_ratio", function()
    describe("when scale has default value (5)", function()
      describe("and zoom is set to 0", function()
        it("should return 1", function()
          assert.is.truthy(camera:get_zoom_aspect_ratio() == 1)
        end)
      end)

      describe("and zoom is set to -1", function()
        it("should return 1.25", function()
          camera:set_zoom(-1)

          assert.is.truthy(camera:get_zoom_aspect_ratio() == 1.25)
        end)
      end)
    end)

    describe("when scale is set to 6", function()
      before_each(function()
        camera.scale = 6
      end)

      describe("and zoom is set to 0", function()
        it("should return 1", function()
          assert.is.truthy(camera:get_zoom_aspect_ratio() == 1)
        end)
      end)

      describe("and zoom is set to -1", function()
        it("should return 1.2", function()
          camera:set_zoom(-1)

          assert.is.truthy(camera:get_zoom_aspect_ratio() == 1.2)
        end)
      end)
    end)

    -- Is this OK behavior?
    describe("when scale is set to 0", function()
      before_each(function()
        camera.scale = 0
      end)

      describe("and zoom is set to 0", function()
        it("should return -nan", function()
          assert.is.truthy(tostring(camera:get_zoom_aspect_ratio()) == "-nan")
        end)
      end)

      describe("and zoom is set to -1", function()
        it("should return -0", function()
          camera:set_zoom(-1)

          assert.is.truthy(camera:get_zoom_aspect_ratio() == -0)
        end)
      end)
    end)
  end)

  describe("pixel_to_screen", function()
    describe("when scale has default value (5)", function()
      describe("and pixel parameter has a valid number value", function()
        it("should return pixel value divided by 5", function()
          assert.is.truthy(camera:pixel_to_screen(128) == 25.6)
          assert.is.truthy(camera:pixel_to_screen(256) == 51.2)
          assert.is.truthy(camera:pixel_to_screen(0.001) == 0.0002)
          assert.is.truthy(camera:pixel_to_screen(-256) == -51.2)
          assert.is.truthy(camera:pixel_to_screen(-128) == -25.6)
          assert.is.truthy(camera:pixel_to_screen(-0.001) == -0.0002)
        end)
      end)
    end)

    describe("and pixel parameter is 0 or nil", function()
      it("should return 0", function()
        assert.is.truthy(camera:pixel_to_screen(0) == 0)
        assert.is.truthy(camera:pixel_to_screen() == 0)
      end)
    end)

    describe("and pixel parameter is a string", function()
      it("should cause error", function()
        assert.has_error(function() camera:pixel_to_screen("") end)
        assert.has_error(function() camera:pixel_to_screen("Hello?") end)
      end)
    end)
  end)

  describe("screen_coordinates", function()
    it("should call pixel_to_screen twice and return two values", function()
      spy.on(camera, "pixel_to_screen")

      local x, y = camera:screen_coordinates(128, 128)

      assert.spy(camera.pixel_to_screen).was.called(2)
      assert.is.falsy(x == nil)
      assert.is.falsy(y == nil)
    end)
  end)

  describe("get_position", function()
    describe("when x and y is not nil", function()
      it("should return the value of x and y", function()
        local x, y

        camera:look_at(128, 128)
        x, y = camera:get_position()
        assert.is.truthy(x == 128, y == 128)

        camera:look_at(256, 256)
        x, y = camera:get_position()
        assert.is.truthy(x == 256, y == 256)

        camera:look_at(0, 0)
        x, y = camera:get_position()
        assert.is.truthy(x == 0, y == 0)

        camera:look_at("Hello", "World")
        x, y = camera:get_position()
        assert.is.truthy(x == "Hello", y == "World")
      end)
    end)
    describe("when x and y is nil", function()
      it("should return 0", function()
        camera:look_at(nil, nil)
        local x, y = camera:get_position()
        assert.is.truthy(x == 0, y == 0)
      end)
    end)
  end)

  describe("world_coordinates", function()
    describe("when screen size is 1280x720", function()
      local half_width, half_height = camera:get_screen_game_half_size()

      describe("and camera.x and camera.y is set to 0", function()
        describe("and screen coordinates are (0, 0)", function()
          it("should return negative half width and height", function()
            local world_x, world_y = camera:world_coordinates(0, 0)
            assert.is.truthy(world_x == -half_width, world_y == -half_height)
          end)
        end)

        describe("and screen coordinates are (32, 64)", function()
          it("should return 32 minus half width and 64 minus half height", function()
            local world_x, world_y = camera:world_coordinates(32, 64)
            assert.is.truthy(world_x == 32 - half_width, world_y == 64 - half_height)
          end)
        end)

        describe("and screen coordinates are half screen size", function()
          it("should return 0", function()
            local world_x, world_y = camera:world_coordinates(half_width, half_height)
            assert.is.truthy(world_x == 0, world_y == 0)
          end)
        end)

        describe("and screen coordinates are full screen size", function()
          it("should return half screen size", function()
            local world_x, world_y = camera:world_coordinates(half_width * 2, half_height * 2)
            assert.is.truthy(world_x == half_width, world_y == half_height)
          end)
        end)
      end)

      describe("and camera.x and camera.y is set to 128 and 256", function()
        local look_at_x, look_at_y = 128, 256

        before_each(function()
          camera:look_at(look_at_x, look_at_y)
        end)

        describe("and screen coordinates are (0, 0)", function()
          it("should return negative half screen size + camera x and y", function()
            local world_x, world_y = camera:world_coordinates(0, 0)
            assert.is.truthy(world_x == -half_width + look_at_x, world_y == -half_height + look_at_y)
          end)
        end)

        describe("and screen coordinates are (32, 64)", function()
          it("should return 32 minus half width and 64 minus half height", function()
            local screen_x, screen_y = 32, 64
            local world_x, world_y = camera:world_coordinates(screen_x, screen_y)
            assert.is.truthy(world_x == screen_x - half_width + look_at_x, world_y == screen_y - half_height + look_at_x)
          end)
        end)

        describe("and screen coordinates are half screen size", function()
          it("should return camera x and y", function()
            local world_x, world_y = camera:world_coordinates(half_width, half_height)
            assert.is.truthy(world_x == look_at_x, world_y == look_at_x)
          end)
        end)

        describe("and screen coordinates are full screen size", function()
          it("should return half screen size + camera x and y", function()
            local world_x, world_y = camera:world_coordinates(half_width * 2, half_height * 2)
            assert.is.truthy(world_x == half_width + look_at_x, world_y == half_height + look_at_y)
          end)
        end)
      end)
    end)
  end)

  describe("toggle_fullscreen", function()
    describe("when is_fullscreen set to false", function()
      it("should call love.window.setFullscree and set is_fullscreen to true", function()
        stub(love.window, "setFullscreen").returns(not (camera.is_fullscreen))
        camera:toggle_fullscreen()

        assert.stub(love.window.setFullscreen).was.called(1)
        assert.stub(love.window.setFullscreen).was.called_with(true, "desktop")
        assert.is.truthy(camera.is_fullscreen)
      end)
    end)

    describe("when is_fullscreen set to true", function()
      it("should call love.window.setFullscree and set is_fullscreen to false", function()
        camera.is_fullscreen = true
        stub(love.window, "setFullscreen").returns(not (camera.is_fullscreen))
        camera:toggle_fullscreen()

        assert.stub(love.window.setFullscreen).was.called(1)
        assert.stub(love.window.setFullscreen).was.called_with(false, "desktop")
        assert.is.falsy(camera.is_fullscreen)
      end)
    end)
  end)

  describe("look_at", function()
    describe("when the parameters x and y has values set", function()
      it("should set cameras x and y to the same value", function()
        camera:look_at(128, 32)
        assert.is:truthy(camera.x == 128, camera.y == 32)

        camera:look_at(-32, -128)
        assert.is:truthy(camera.x == -32, camera.y == -128)

        camera:look_at(0, 0)
        assert.is:truthy(camera.x == 0, camera.y == 0)

        camera:look_at("Hello", "World!")
        assert.is:truthy(camera.x == "Hello", camera.y == "World!")

        camera:look_at("", "")
        assert.is:truthy(camera.x == "", camera.y == "")
      end)

      describe("when the parameters x and y does not have any values", function()
        it("should set cameras x and y to 0", function()
          camera.x, camera.y = 128, 32

          camera:look_at()
          assert.is:truthy(camera.x == 0, camera.y == 0)
        end)
      end)
    end)

    describe("is_outside_camera_view", function()
      describe("when the entity top-left is in the center of the screen", function()
        it("should not be outside of camera view", function()
          assert.is.falsy(camera:is_outside_camera_view(vector2.zero(), vector2.one()))
        end)
      end)

      describe("when the entity top-left is in the bottom-right corner of the screen", function()
        it("should not be outside of camera view", function()
          local world_x, world_y = world_grid:world_to_grid(camera:get_screen_game_half_size())

          assert.is.falsy(camera:is_outside_camera_view(vector2(world_x, world_y), vector2(1, 1 )))
        end)
      end)

      describe("when the entity top-left is in the top-left corner of the screen", function()
        it("should not be outside of camera view", function()
          local world_x, world_y = world_grid:world_to_grid(camera:get_screen_game_half_size())

          assert.is.falsy(camera:is_outside_camera_view(vector2(world_x, world_y), vector2(1, 1)))
        end)
      end)

      describe("when the entity top-left has passed the top-left corner of the screen", function()
        it("should not be outside of camera view", function()
          local world_x, world_y = world_grid:world_to_grid(camera:get_screen_game_half_size())

          assert.is.truthy(camera:is_outside_camera_view(vector2(world_x + 1, world_y + 1), vector2(1, 1)))
        end)
      end)
    end)
  end)

  describe("start_draw_world", function()
    it("should setup the canvas_game, clear it and center position the camera view", function()
      stub(love.graphics, "setCanvas")
      stub(love.graphics, "clear")
      stub(love.graphics, "push")
      stub(love.graphics, "translate")
      camera:look_at(world_grid:world_to_grid(16, 32))

      camera:start_draw_world()

      local half_width, half_height = camera:get_screen_game_half_size()
      assert.stub(love.graphics.setCanvas).was.called(1)
      assert.stub(love.graphics.setCanvas).was.called_with(camera.canvas_game)
      assert.stub(love.graphics.clear).was.called(1)
      assert.stub(love.graphics.clear).was.called_with(0.18039215686, 0.13333333333, 0.18431372549, 1)
      assert.stub(love.graphics.push).was.called(1)
      assert.stub(love.graphics.translate).was.called(2)
      assert.stub(love.graphics.translate).was.called_with(math.round(half_width), math.round(half_height))
      assert.stub(love.graphics.translate).was.called_with(-16, -32)
    end)
  end)

  describe("stop_draw_world", function()
    describe("when scale and zoom has default values (5 and 0)", function()
      it("should draw the canvas_game and reverse the push operation with default scale value", function()
        stub(love.graphics, "setCanvas")
        stub(love.graphics, "pop")
        stub(love.graphics, "draw")

        camera:stop_draw_world()

        assert.stub(love.graphics.setCanvas).was.called(1)
        assert.stub(love.graphics.pop).was.called(1)
        assert.is.truthy(camera.scale + camera.zoom == default_scale)
        assert.stub(love.graphics.draw).was.called_with(camera.canvas_game, 0, 0, 0, camera.scale + camera.zoom)
      end)
    end)
  end)

  describe("when scale has default value (5) but zoom is set to -1", function()
    it("should draw the canvas_game and reverse the push operation with 4 in scale", function()
      stub(love.graphics, "setCanvas")
      stub(love.graphics, "pop")
      stub(love.graphics, "draw")

      camera:set_zoom(-1)
      camera:stop_draw_world()

      assert.stub(love.graphics.setCanvas).was.called(1)
      assert.stub(love.graphics.pop).was.called(1)
      assert.is.truthy(camera.scale + camera.zoom == 4)
      assert.stub(love.graphics.draw).was.called_with(camera.canvas_game, 0, 0, 0, camera.scale + camera.zoom)
    end)
  end)

  describe("start_draw_hud", function()
    it("should setup the canvas_hud and clear it", function()
      stub(love.graphics, "setCanvas")
      stub(love.graphics, "clear")

      camera:start_draw_hud()

      assert.stub(love.graphics.setCanvas).was.called(1)
      assert.stub(love.graphics.setCanvas).was.called_with(camera.canvas_hud)
      assert.stub(love.graphics.clear).was.called(1)
      assert.stub(love.graphics.clear).was.called_with(0, 0, 0, 0)
    end)
  end)

  describe("stop_draw_hud", function()
    it("should draw the canvas_hud", function()
      stub(love.graphics, "setCanvas")
      stub(love.graphics, "draw")

      camera:stop_draw_hud()

      assert.stub(love.graphics.setCanvas).was.called(1)
      assert.stub(love.graphics.setCanvas).was.called_with()
      assert.stub(love.graphics.draw).was.called(1)
      assert.stub(love.graphics.draw).was.called_with(camera.canvas_hud)
    end)
  end)

  describe("get_scale", function()
    it("should return cameras scale value", function()
      assert.is.truthy(camera:get_scale() == default_scale)

      camera.scale = 1
      assert.is.truthy(camera:get_scale() == 1)

      camera.scale = -13
      assert.is.truthy(camera:get_scale() == -13)

      camera.scale = "donut"
      assert.is.truthy(camera:get_scale() == "donut")

      camera.scale = nil
      assert.is.truthy(camera:get_scale() == 0)
    end)
  end)

  describe("get_zoom", function()
    it("should return cameras zoom value", function()
      assert.is.truthy(camera:get_zoom() == default_zoom)

      camera.zoom = 1
      assert.is.truthy(camera:get_zoom() == 1)

      camera.zoom = -13
      assert.is.truthy(camera:get_zoom() == -13)

      camera.zoom = "donut"
      assert.is.truthy(camera:get_zoom() == "donut")

      camera.zoom = nil
      assert.is.truthy(camera:get_zoom() == 0)
    end)
  end)

  describe("set_zoom", function()
    describe("when zoom is set to a higher value than 0", function()
      it("should set the zoom to 0", function()
        camera:set_zoom(0.01)
        assert.is.truthy(camera:get_zoom() == ZOOM_MIN)

        camera.zoom = 0

        camera:set_zoom(128)
        assert.is.truthy(camera:get_zoom() == ZOOM_MIN)
      end)
    end)

    describe("when zoom is set to a lower value than " .. ZOOM_MAX, function()
      it("should set the zoom to " .. ZOOM_MAX, function()
        camera:set_zoom(ZOOM_MAX - 0.00001)
        assert.is.truthy(camera:get_zoom() == ZOOM_MAX)

        camera.zoom = 0

        camera:set_zoom(-128)
        assert.is.truthy(camera:get_zoom() == ZOOM_MAX)
      end)
    end)

    describe("when zoom is set between 0 and " .. ZOOM_MAX, function()
      it("should set the actual value for camera zoom", function()
        camera:set_zoom(-0.25)
        assert.is.truthy(camera:get_zoom() == -0.25)

        camera.zoom = 0

        camera:set_zoom(ZOOM_MAX + 0.000001)
        assert.is.truthy(camera:get_zoom() == ZOOM_MAX + 0.000001)
      end)
    end)
  end)

  describe("can_zoom_out", function()
    describe("when zoom is larger than " .. ZOOM_MAX, function()
      it("should return true", function()
        assert.is.truthy(camera:can_zoom_out())

        camera.zoom = -1
        assert.is.truthy(camera:can_zoom_out())

        camera.zoom = -2
        assert.is.truthy(camera:can_zoom_out())
      end)
    end)

    describe("when zoom is equal to " .. ZOOM_MAX, function()
      it("should return false", function()
        camera.zoom = ZOOM_MAX
        assert.is.falsy(camera:can_zoom_out())
      end)
    end)
  end)

  describe("can_zoom_in", function()
    describe("when zoom is less than " .. ZOOM_MAX, function()
      it("should return true", function()
        camera.zoom = ZOOM_MAX
        assert.is.truthy(camera:can_zoom_in())

        camera.zoom = -1
        assert.is.truthy(camera:can_zoom_in())

        camera.zoom = -2
        assert.is.truthy(camera:can_zoom_in())
      end)
    end)

    describe("when zoom is equal to " .. ZOOM_MIN, function()
      it("should return false", function()
        assert.is.falsy(camera:can_zoom_in())
      end)
    end)
  end)

  describe("set_canvas_game", function()
    it("should setup the canvas_game", function()
      local stub_canvas = {}

      stub(love.graphics, "newCanvas").returns(stub_canvas)
      stub(stub_canvas, "setFilter")

      camera:set_canvas_game(1280, 720)

      assert.stub(love.graphics.newCanvas).was.called_with(1280, 720)
      assert.stub(stub_canvas.setFilter).was.called_with(stub_canvas, "nearest", "nearest")
      assert.are.equal(camera.canvas_game, stub_canvas)
    end)
  end)

  describe("set_canvas_hud", function()
    it("should setup the canvas_hud", function()
      local stub_canvas = {}

      stub(love.graphics, "newCanvas").returns(stub_canvas)
      stub(stub_canvas, "setFilter")

      camera:set_canvas_hud(1280, 720)

      assert.stub(love.graphics.newCanvas).was.called_with(1280, 720)
      assert.stub(stub_canvas.setFilter).was.called_with(stub_canvas, "nearest", "nearest")
      assert.are.equal(stub_canvas, camera.canvas_hud)
    end)
  end)

  describe("load", function()
    it("should call set_canvas_game and set_canvas_hud", function()
      local width, height = camera:get_screen_game_size()
      local scaled_width, scaled_height = width * camera:get_scale(), height * camera:get_scale()

      stub(camera, "set_canvas_game")
      stub(camera, "set_canvas_hud")

      camera:load()

      assert.stub(camera.set_canvas_game).was.called_with(camera, width, height)
      assert.stub(camera.set_canvas_hud).called_with(camera, scaled_width, scaled_height)
    end)
  end)
end)

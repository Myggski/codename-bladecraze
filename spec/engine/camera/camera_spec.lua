require "spec.love_setup"

insulate("camera", function()
  local camera = require "code.engine.camera.camera"
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
    describe("when scale is set to five", function()
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

    describe("when scale is set to five", function()
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
      local half_width, half_height = camera:get_screen_game_half_size();

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
end)

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
  end)

  describe("get_screen_game_size", function()
    describe("when scale is set to five", function()
      describe("and zoom is set to zero", function()
        it("should return 1280 and 720 divided by five", function()
          local w, h = camera:get_screen_game_size()

          assert.is_true(w == 256)
          assert.is_true(h == 144)
        end)
      end)

      describe("and zoom is set to minus one", function()
        it("should return 1280 and 720 divided by four", function()
          camera:set_zoom(-1)
          local w, h = camera:get_screen_game_size()

          assert.is_true(w == 320)
          assert.is_true(h == 180)
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
          assert.is_true(w == 128)
          assert.is_true(h == 72)
        end)
      end)

      describe("and zoom is set to minus one", function()
        it("should return 640 and 360 divided by four", function()
          camera:set_zoom(-1)
          local w, h = camera:get_screen_game_half_size()

          assert.spy(get_screen_game_size_spy).was.called()
          assert.is_true(w == 160)
          assert.is_true(h == 90)
        end)
      end)
    end)
  end)

  describe("get_zoom_aspect_ratio", function()
    describe("when scale has default value", function()
      describe("and zoom is set to 0", function()
        it("should return 1", function()
          assert.is_true(camera:get_zoom_aspect_ratio() == 1)
        end)
      end)

      describe("and zoom is set to -1", function()
        it("should return 1.25", function()
          camera:set_zoom(-1)

          assert.is_true(camera:get_zoom_aspect_ratio() == 1.25)
        end)
      end)
    end)

    describe("when scale is set to 6", function()
      before_each(function()
        camera.scale = 6
      end)

      describe("and zoom is set to 0", function()
        it("should return 1", function()
          assert.is_true(camera:get_zoom_aspect_ratio() == 1)
        end)
      end)

      describe("and zoom is set to -1", function()
        it("should return 1.2", function()
          camera:set_zoom(-1)

          assert.is_true(camera:get_zoom_aspect_ratio() == 1.2)
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
          assert.is_true(tostring(camera:get_zoom_aspect_ratio()) == "-nan")
        end)
      end)

      describe("and zoom is set to -1", function()
        it("should return -0", function()
          camera:set_zoom(-1)

          assert.is_true(camera:get_zoom_aspect_ratio() == -0)
        end)
      end)
    end)
  end)
end)

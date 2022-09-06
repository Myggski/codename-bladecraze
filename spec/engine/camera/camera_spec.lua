insulate("camera", function()
  local camera = require "code.engine.camera.camera"
  local love_mock = require "spec.love_mock"

  before_each(function()
    love_mock()
        :set_screen_size(1280, 720)
        :build()
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
end)

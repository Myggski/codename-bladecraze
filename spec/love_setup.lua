package.preload.love = package.loadlib("/usr/lib/x86_64-linux-gnu/liblove-11.4.so", "luaopen_love")
require "love"
require "code.engine.constants.global_types"
require "code.engine.constants.game_data"
require "code.engine.extensions.math_extension"
require "code.engine.extensions.table_extension"

love.window = {}
love.graphics = {}
love.timer = {
  getTime = function()
    return os.time()
  end,
}

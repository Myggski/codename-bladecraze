package.preload.love = package.loadlib('/usr/lib/x86_64-linux-gnu/liblove-11.4.so', 'luaopen_love')
require 'love'
require "code.engine.constants.global_types"
require 'code.utilities.math_extension'
require 'code.utilities.table_extension'

love.window = {}
love.graphics = {}
love.timer = {
  getTime = function()
    return os.time()
  end,
}

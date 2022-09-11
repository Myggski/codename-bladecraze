package.preload.love = package.loadlib('/usr/lib/x86_64-linux-gnu/liblove-11.4.so', 'luaopen_love')
require 'love'
require 'love.filesystem'
require 'love.graphics'
love.filesystem.init(arg[-1])

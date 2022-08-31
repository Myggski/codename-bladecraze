package = "codename-bladecraze"
version = "0.0.1-1"

source = {
   url = "git+https://github.com/myggski/lua-todo",
}

description = {
   summary = "Survival game made with LÖVE",
}

dependencies = {
   "lua = 5.2",
   "json-lua >= 0.1-3",
   "busted >= 2.1.1-1",
   "luacov >= 0.15.0-1",
}

build = {
   type = "builtin",
   modules = {
      main = "main.lua"
   }
}
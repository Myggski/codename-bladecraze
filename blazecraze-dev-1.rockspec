
package = "blazecraze"
version = "dev-1"

source = {
   url = "git+https://github.com/myggski/codename-blazecraze",
}

description = {
   summary = "Survival game made in LÖVE",
}

dependencies = {
   "busted",
   "luacov",
}

build = {
   type = "builtin",
   modules = {
      main = "main.lua"
   }
}
local game_event_manager = require("code.engine.game_event.game_event_manager")

local font_silver = {
  normal = nil
}

local function load()
  print("LOAD")
  font_silver.normal = love.graphics.newFont("assets/fonts/Silver.ttf", 16, "normal")
  font_silver.normal:setFilter("nearest", "nearest")
end

function font_silver:set_normal_font()
  
  love.graphics.setFont(self.normal)
end

if (font_silver.normal == nil) then
  game_event_manager:add_listener(GAME_EVENT_TYPES.LOAD, load)
end

return font_silver
local game_event_manager = require("code.engine.game_event.game_event_manager")

local font_silver = {
  normal = nil,
}

-- -- local function load()
-- --   font_silver.normal = love.graphics.newFont("assets/fonts/Silver.ttf", 16, "normal")
-- -- end

-- function font_silver:set_normal_font()
--   love.graphics.setFont(self.normal)
-- end

function font_silver:get_text_size(font, text)
  return font:getWidth(text), font:getHeight()
end

if (font_silver.normal == nil) then
  game_event_manager:add_listener(GAME_EVENT_TYPES.LOAD, load)
end

return font_silver

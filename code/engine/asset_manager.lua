local prototypes = require("code.utilities.prototypes")

local asset_manager = {}
local category = prototypes.asset_category

asset_manager.images = category:new { dir = "assets/images/", }
asset_manager.fonts = category:new { dir = "assets/fonts/", }
asset_manager.audio = category:new { dir = "assets/audio/", }

local images, audio, fonts = asset_manager.images, asset_manager.audio, asset_manager.fonts

function asset_manager:get_image(name)
  local path = images.dir .. name
  if table.contains_key(images.loaded_data, path) then
    print("found existing image")
    return images.loaded_data[path]
  end

  local image = love.graphics.newImage(path)
  image:setFilter("nearest", "nearest")
  images.loaded_data[path] = image
  return image
end

function asset_manager:get_audio(name, audio_type)
  local path = audio.dir .. name

  if table.contains_key(audio.loaded_data, path) then
    return audio.loaded_data[path]
  end

  audio_type = audio_type or "static"
  audio.loaded_data[path] = love.audio.newSource(path, audio_type)
  return audio.loaded_data[path]
end

function asset_manager:get_font(name, font_size, hinting_mode)
  local path = fonts.dir .. name
  if table.contains_key(fonts.loaded_data, path) then
    print("found existing font")
    return fonts.loaded_data[path]
  end

  font_size = font_size or 16
  hinting_mode = hinting_mode or "normal"

  local font = love.graphics.newFont(path, font_size, hinting_mode)
  fonts.loaded_data[path] = font
  return font
end

return asset_manager

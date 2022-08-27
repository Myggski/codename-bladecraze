local camera = require "code.engine.camera"

local asset_manager = {
  images = { dir = "assets/images/", loaded_data = {} },
  fonts = { dir = "assets/fonts/", loaded_data = {} },
  audio = { dir = "assets/audio/", loaded_data = {} },
}

local images = asset_manager.images
local audio = asset_manager.audio
local fonts = asset_manager.fonts

local function get_asset(file_path, asset_table)
  local is_loaded, asset = false, nil
  is_loaded = table.contains_key(asset_table.loaded_data, file_path)
  asset = asset_table.loaded_data[file_path]

  return is_loaded, asset
end

--[[
  Returns the width and height of the text.
  Subtracts 2 of height because the fonts is not centered for some reason
]]
function asset_manager:get_text_size(font, text)
  return font:getWidth(text), font:getHeight() - (2 * camera.scale)
end

--[[
  Create a new unique pixel image, or return existing one with same path
]]
function asset_manager:get_image(file_name)
  local file_path = images.dir .. file_name
  local storage_path = file_name
  local is_loaded, asset = get_asset(storage_path, images)

  if is_loaded then
    return asset
  end

  local image = love.graphics.newPixelImage(file_path)
  images.loaded_data[storage_path] = image
  return image
end

--[[
  Create a new unique audio source for a file.
  unique_id makes it possible for more sources to exist.
]]
function asset_manager:get_audio(file_name, audio_type, unique_id)
  audio_type = audio_type or "static"
  unique_id = unique_id or ""

  local file_path = audio.dir .. file_name
  local storage_path = file_name .. audio_type .. unique_id
  local is_loaded, asset = get_asset(storage_path, audio)
  if is_loaded then
    return asset
  end

  audio.loaded_data[storage_path] = love.audio.newSource(file_path, audio_type)
  return audio.loaded_data[storage_path]
end

--[[
  Create a new unique font or retrieve existing one with same parameters.
]]
function asset_manager:get_font(file_name, font_size, hinting_mode)
  font_size = font_size or 16
  hinting_mode = hinting_mode or "normal"

  local file_path = fonts.dir .. file_name
  local storage_path = file_name .. hinting_mode .. font_size
  local is_loaded, asset = get_asset(storage_path, fonts)

  if is_loaded then
    return asset
  end

  local font = love.graphics.newFont(file_path, font_size * camera.scale, hinting_mode)
  fonts.loaded_data[storage_path] = font
  return font
end

return asset_manager

function love.graphics.newPixelImage(image_url)
  local image = love.graphics.newImage(image_url)
  image:setFilter("nearest", "nearest")

  return image
end
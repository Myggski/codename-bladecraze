local function draw(image, quad, rectangle)
  love.graphics.draw(image, quad, rectangle.x, rectangle.y)
end

return {
  draw = draw,
}
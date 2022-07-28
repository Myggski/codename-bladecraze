
local animations = {}

function animations.newAnimation(data)

    local animation = {}
    animation.quads = {};
    animation.spriteSheet = data.image;
    animation.duration = data.duration
    animation.currentTime = 0

    local i = 0;
    for y = data.offsetY, data.image:getHeight() - data.height, data.height do
        for x = data.offsetX, data.image:getWidth() - data.width, data.width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, data.width, data.height, data.image:getDimensions()))
            i = i + 1
            if (i >= data.frameCount) then
                return animation
            end
        end
    end
    return animation
end

return animations
local utils = {}

function utils.loadSprite(path)
    local img = love.graphics.newImage(path)
    return {
        image = img,
        width = img:getWidth(),
        height = img:getHeight()
    }
end

return utils
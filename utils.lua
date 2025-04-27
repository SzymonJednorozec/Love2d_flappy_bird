local love = require "love"

local utils = {}

function utils.loadSprite(path)
    local img = love.graphics.newImage(path)
    return {
        image = img,
        width = img:getWidth(),
        height = img:getHeight()
    }
end

function utils.saveHighScore(score)
    local data = tostring(score)
    love.filesystem.write("highscore.dat", data)
end

function utils.loadHighScore()
    if love.filesystem.getInfo("highscore.dat") then
        local data = love.filesystem.read("highscore.dat")
        return tonumber(data)
    end
    return 0
end


return utils
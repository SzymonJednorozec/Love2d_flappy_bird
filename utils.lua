local love = require "love"
local bitser = require "bitser"

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
    local info = love.filesystem.getInfo("highscore.dat")
    if info and info.size > 0 then
        local data = love.filesystem.read("highscore.dat")
        return tonumber(data) or 0      -- poprawny zapis
    else
        return 0                         -- brak pliku lub pusty
    end
end


return utils
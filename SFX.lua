local love = require "love"

local SFX = {}
SFX.effects = {
    shoot = {
        source = love.audio.newSource("sounds/shoot.wav", "static"),
        volume = 0.1
    },
    hit = {
        source = love.audio.newSource("sounds/hit.wav", "static"),
        volume = 0.05
    },
    dead = {
        source = love.audio.newSource("sounds/dead.wav", "static"),
        volume = 0.14
    },
    explosion1 = {
        source = love.audio.newSource("sounds/explosion.wav", "static"),
        volume = 0.03
    },
    explosion2 = {
        source = love.audio.newSource("sounds/enemy_explosion.wav", "static"),
        volume = 0.03
    },
    coin = {
        source = love.audio.newSource("sounds/coin.wav", "static"),
        volume = 0.1
    },
    score = {
        source = love.audio.newSource("sounds/score.wav", "static"),
        volume = 0.01
    }
}

function SFX.play(name)
    local effect = SFX.effects[name]
    local instance = effect.source:clone()
    local volume = effect.volume
    instance:setVolume(volume)
    instance:play()
end

return SFX
local love = require "love"
_G.screen_width = 1000
_G.screen_height = 800
function love.conf(t)
    t.window.width = screen_width
    t.window.height = screen_height
end
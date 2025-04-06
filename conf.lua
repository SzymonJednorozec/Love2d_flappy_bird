local love = require "love"
_G.screen_width = 1400
_G.screen_height = 900
function love.conf(t)
    t.window.width = screen_width
    t.window.height = screen_height
end
local love = require "love"
local Menu = {}

function Menu.drawGameover()
    love.graphics.printf("Game Over",love.graphics.newFont(40),screen_width/2-150,screen_height/2-100,screen_width)
    love.graphics.printf("Press enter to continue",love.graphics.newFont(20),screen_width/2-140,screen_height/2,screen_width)
end

function Menu.drawMenu(background)
    -- background = bg:clone() 
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.draw(background.image,0,0,0,screen_width/background.width,screen_height/background.height)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("Strugala",love.graphics.newFont(40),screen_width / 2 - 300 / 2,screen_height/2-100,300,"center")
    love.graphics.printf("Press space to start",love.graphics.newFont(20),screen_width / 2 - 300 / 2,screen_height/2,300,"center")
end

return Menu
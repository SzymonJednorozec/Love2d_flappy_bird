local love = require "love"
local Menu = {}

local resolutions = {
    { width = 800, height = 600 },
    { width = 1024, height = 768 },
    { width = 1280, height = 720 },
    { width = 1600, height = 900 },
    { width = 1920, height = 1080 }
}

local selectedOption = 1
local isSelecting = true

function Menu.keypressed(key)
    if isSelecting then
        if key == "up" then
            selectedOption = selectedOption - 1
            if selectedOption < 1 then
                selectedOption = #resolutions
            end
        elseif key == "down" then
            selectedOption = selectedOption + 1
            if selectedOption > #resolutions then
                selectedOption = 1
            end
        elseif key == "return" then
            local res = resolutions[selectedOption]
            love.window.setMode(res.width, res.height, { fullscreen = false, resizable = false })
            screen_width = res.width
            screen_height = res.height
        end
    end
end

function Menu.gamerunning()
    isSelecting=false
end

function Menu.menurunning()
    isSelecting=true
end

function Menu.drawMenu(background)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.draw(background.image, 0, 0, 0, screen_width/background.width, screen_height/background.height)

    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Strugala",love.graphics.newFont(40),screen_width / 2 - 300 / 2,100,300,"center")
    love.graphics.printf("Press space to start",love.graphics.newFont(20),screen_width / 2 - 300 / 2,200,300,"center")

    love.graphics.printf("Chose your screen resolution", love.graphics.newFont(18), screen_width/2 - 300/2, 270, 300, "center")
    love.graphics.printf("Arrow up and down to select and enter to confirm", love.graphics.newFont(12), screen_width/2 - 300/2, 300, 300, "center")

    for i, res in ipairs(resolutions) do
        local text = res.width .. "x" .. res.height
        if i == selectedOption then
            love.graphics.setColor(1, 1, 0) 
        else
            love.graphics.setColor(1, 1, 1) 
        end
        love.graphics.printf(text, love.graphics.newFont(12), screen_width/2 - 200/2, 300 + i * 40, 200, "center")
    end
end

return Menu
local love = require "love"
local Vector = require "vector"
local newPlayer = require "player"
local newPipe = require "pipe"
local newBullet = require "bullet"
local Timer = require "timer"
local newEnemy = require "enemy"

local HC = require "hc"  

local collider = HC.new()
local player_col 
local pipe_up_col = {}
local pipe_down_col = {}

local pipe_timer = Timer.new()
local pipes = {}
local bullets = {}
local player
local enemy
local score=0


local mouse 

local game = {
    state = {
        menu=false,
        paused=false,
        running=true,
        ended=false
    }
}

-------------------------------------------------load
function love.load()
    player = newPlayer()
    enemy = newEnemy()
    player_col = collider:circle(player.pos.x, player.pos.y, player.r)
    set_timer(pipe_timer)
end

-------------------------------------------------update
function love.update(dt)
    if game.state.running then
        --Timer
        pipe_timer:update(dt)
        --Pipes
        for _,p in ipairs(pipes) do p:move(dt) end
        pipe_del()
        --Player
        local mx, my = love.mouse.getPosition()
        mouse = Vector(mx,my)
        player:move(mouse,dt)
        enemy:move(player.pos,dt)
        --bullets
        for _, b in ipairs(bullets) do b:move(dt) end
        --colliders
        player_col:moveTo(player.pos.x, player.pos.y)
        move_to_for_pipes()
        checking_player_collisions()
        player_out_of_boundaries()
        
    end

end
-------------------------------------------------draw
function love.draw()
    --ended
    if game.state.ended then
        love.graphics.printf("Game Over",love.graphics.newFont(40),screen_width/2-150,screen_height/2-100,screen_width)
        love.graphics.printf("Press enter to restart",love.graphics.newFont(20),screen_width/2-140,screen_height/2,screen_width)
    end
    --running
    if game.state.running then
        love.graphics.printf("Points: " .. score,love.graphics.newFont(20),30,30,screen_width)
        --Player
        player:draw()
        enemy:draw()
        for _, b in ipairs(bullets) do b:draw() end
        for _, p in ipairs(pipes) do p:draw() end
    end
end
-----------------------------------------------

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        player.jump=true
        table.insert(bullets,newBullet(player.pos,(mouse - player.pos):normalized()))
    end
    if key == "right" then
        game.state.running=true
        game.state.ended=false
        game.state.menu=false
        player.pos=Vector(400,400)
        player.vel=Vector(0,0)
        for i = 1, #pipe_up_col  do
            collider:remove(pipe_up_col[i])
            collider:remove(pipe_down_col[i])  
        end
        collider:remove(player_col)
        pipes={}
        pipe_up_col={}
        pipe_down_col={}
        score=0

        player_col = collider:circle(player.pos.x, player.pos.y, player.r)


        pipe_timer = Timer.new()
        set_timer(pipe_timer)
    end
 end


 function player_out_of_boundaries()
    if player.pos.x<0 or player.pos.x>screen_width then
        game.state.running=false
        game.state.ended=true
    elseif  player.pos.y<0 or player.pos.y>screen_height then
        game.state.running=false
        game.state.ended=true
    end
 end

function checking_player_collisions()
    for shape, delta in pairs(collider:collisions(player_col)) do
        game.state.running=false
        game.state.ended=true
    end
end

function move_to_for_pipes()
    for i = 1, #pipe_up_col  do
        pipe_up_col[i]:moveTo(pipes[i].pos.x, pipes[i].pos.y - pipes[i].gap/2 - pipes[i].height/2)
        pipe_down_col[i]:moveTo(pipes[i].pos.x, pipes[i].pos.y + pipes[i].gap/2 + pipes[i].height/2)
    end
end

 function pipe_del()
    for i = #pipes, 1, -1 do
        if pipes[i].pos.x < player.pos.x - 25 then
            collider:remove(pipe_up_col[i]) 
            collider:remove(pipe_down_col[i]) 
            table.remove(pipes, i)
            table.remove(pipe_up_col, i)
            table.remove(pipe_down_col, i)
            score = score + 1
        end
    end
end

function set_timer(given_timer)
    given_timer:every(2, function()
        local new_pipe = newPipe()
        table.insert(pipes, new_pipe)
        table.insert(pipe_up_col, collider:rectangle(new_pipe.pos.x - new_pipe.width/2, new_pipe.pos.y - new_pipe.gap/2 - new_pipe.height, new_pipe.width, new_pipe.height))
        table.insert(pipe_down_col, collider:rectangle(new_pipe.pos.x - new_pipe.width/2, new_pipe.pos.y + new_pipe.gap/2, new_pipe.width, new_pipe.height))
    end)
end
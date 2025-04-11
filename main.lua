local love = require "love"
local Vector = require "vector"
local newPlayer = require "player"
local newPipe = require "pipe"
local newBullet = require "bullet"
local Timer = require "timer"
local newEnemy = require "enemy"
local newCoin = require "coin"

local HC = require "hc"  

local collider = HC.new()
local player_col 


local pipe_timer = Timer.new()
local tween_timer = Timer.new()
local pipes = {}
local bullets = {}
local player
local enemies={}
local coins={}
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
    player_col = collider:circle(player.pos.x, player.pos.y, player.r)
    player_col.object_type="player"
    set_timer(pipe_timer)
end

-------------------------------------------------update
function love.update(dt)
    if game.state.running then
        --Timer
        pipe_timer:update(dt)
        tween_timer:update(dt)
        --Pipes
        for _,p in ipairs(pipes) do p:move(dt) end
        pipe_del()
        --Player
        local mx, my = love.mouse.getPosition()
        mouse = Vector(mx,my)
        player:move(mouse,dt)
        --enemies bullets coins
        for _, e in ipairs(enemies) do e:move(player.pos,dt) end
        for _, b in ipairs(bullets) do b:move(dt) end
        for _, c in ipairs(coins) do c:move(dt) end

        --colliders
        player_col:moveTo(player.pos.x, player.pos.y)
        checking_all_collisions()
        player_out_of_boundaries()
        bullets_out_of_boundaries()
        destroy_enemy_if_dead()
        
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
        for _, e in ipairs(enemies) do e:draw() end
        for _, b in ipairs(bullets) do b:draw() end
        for _, p in ipairs(pipes) do p:draw() end
        for _, c in ipairs(coins) do c:draw() end
    end
end
-----------------------------------------------functions

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        player.jump=true
        local new_bullet = newBullet(collider,player.pos:clone(),(mouse - player.pos):normalized())
        table.insert(bullets,new_bullet)
    end
    if key == "right" then
        game.state.running=true
        game.state.ended=false
        game.state.menu=false
        reset_everything()
    end
 end


function reset_everything()

    player.pos=Vector(400,400)
    player.vel=Vector(0,0)
    collider:remove(player_col)

    for i = 1, #pipes  do
        collider:remove(pipes[i].collider1)
        collider:remove(pipes[i].collider2)  
    end
    pipes={}

    for i = 1, #enemies  do
        collider:remove(enemies[i].collider)  
    end
    enemies={}

    for i = 1, #bullets do
        collider:remove(bullets[i].collider)  
    end
    bullets={}

    for i = 1, #coins do
        collider:remove(coins[i].collider)  
    end
    coins={}

    score=0

    player_col = collider:circle(player.pos.x, player.pos.y, player.r)
    player_col.object_type="player"

    pipe_timer = Timer.new()
    set_timer(pipe_timer)
end

function player_out_of_boundaries()
    if player.pos.x<0 or player.pos.x>screen_width or player.pos.y<0 or player.pos.y>screen_height then
        game.state.running=false
        game.state.ended=true
    end
end

function bullets_out_of_boundaries()
    for i = #bullets , 1 , -1 do
        local b = bullets[i]
        if b.pos.x<0 or b.pos.x>screen_width or b.pos.y<0 or b.pos.y>screen_height then
            destroy_bullet(i)
        end
    end
end

function coins_out_of_boundaries()
    for i = #coins , 1 , -1 do
        local c = coins[i]
        if c.pos.x<0 or c.pos.x>screen_width or c.pos.y<0 or c.pos.y>screen_height then
            destroy_coin(i)
        end
    end
end

function destroy_coin(i)
    collider:remove(coins[i].collider)
    table.remove(coins,i)
end

function pickup_coin(i)
    score=score+5
    collider:remove(coins[i].collider)
    table.remove(coins,i)
end

function destroy_enemy_if_dead()
    for i=#enemies, 1, -1 do
        e = enemies[i]
        if e.is_dead then
            local new_coin = newCoin(collider,e.pos)
            move_up(new_coin)
            table.insert(coins,new_coin)
            collider:remove(e.collider)
            table.remove(enemies,i)
        end
    end
end

function destroy_bullet(i)
    collider:remove(bullets[i].collider) 
    table.remove(bullets, i)
end

---------------------------------------------------------------------Checking collisions
function checking_all_collisions()
    for other, delta in pairs(collider:collisions(player_col)) do
        local t1 = player_col.object_type
        local t2 = other.object_type
    
        if (t1 == "player" and (t2 == "pipe" or t2 == "enemy")) then
            game.state.running = false
            game.state.ended = true
        end
    end

    for i = #bullets, 1, -1 do
        local b = bullets[i]
        for other, delta in pairs(collider:collisions(b.collider)) do
            local t1 = other.object_type
    
            if t1 == "enemy" then
                other.parent:getHit(b.direction:clone(),1)
                destroy_bullet(i)  
                break 
            elseif t1 == "pipe" then
                destroy_bullet(i)
                break
            end
        end
    end

    for i = #coins, 1, -1 do
        local c = coins[i]
        for other, delta in pairs(collider:collisions(c.collider)) do
            local t1 = other.object_type

            if t1 == "enemy" or t1 == "pipe" then
                destroy_coin(i)
                break 
            elseif t1 == "player" then
                pickup_coin(i)
                break
            end
        end
    end

end


 function pipe_del()
    for i = #pipes, 1, -1 do
        if pipes[i].pos.x < player.pos.x - 25 then
            collider:remove(pipes[i].collider1) 
            collider:remove(pipes[i].collider2)  
            table.remove(pipes, i)
            score = score + 1
        end
    end
end

function set_timer(given_timer)
    given_timer:every(2, function()
        local new_pipe = newPipe(collider)
        table.insert(pipes, new_pipe)
    end)

    given_timer:every(5, function()
        local enemy = newEnemy(collider)
        table.insert(enemies, enemy)
    end)

end

-----------------------------------------------Tween functions

function move_up(object)
    local new_pos = object.y - 70
    tween_timer:tween(2, object, { y = new_pos }, 'in-out-sine', function()
        move_down(object)
    end)
end

function move_down(object)
    local new_pos = object.y + 70
    tween_timer:tween(2, object, { y = new_pos }, 'in-out-sine', function()
        move_up(object)
    end)
end
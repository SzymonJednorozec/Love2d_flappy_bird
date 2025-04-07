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
local bullets_col = {}
local enemy_col = {}

local pipe_timer = Timer.new()
local pipes = {}
local bullets = {}
local player
local enemies={}
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
        --Pipes
        for _,p in ipairs(pipes) do p:move(dt) end
        pipe_del()
        --Player
        local mx, my = love.mouse.getPosition()
        mouse = Vector(mx,my)
        player:move(mouse,dt)
        --enemies
        for _, e in ipairs(enemies) do e:move(player.pos,dt) end
        --bullets
        for _, b in ipairs(bullets) do b:move(dt) end
        --colliders
        player_col:moveTo(player.pos.x, player.pos.y)
        move_to_for_bullets()
        move_to_for_enemies()
        move_to_for_pipes()
        checking_player_collisions()
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
    end
end
-----------------------------------------------

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        player.jump=true
        local new_bullet = newBullet(player.pos:clone(),(mouse - player.pos):normalized())
        local new_bullet_col = collider:circle(new_bullet.pos.x, new_bullet.pos.y, new_bullet.r)
        table.insert(bullets,new_bullet)
        table.insert(bullets_col, new_bullet_col)
        new_bullet_col.object_type="bullet"

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

    for i = 1, #pipe_up_col  do
        collider:remove(pipe_up_col[i])
        collider:remove(pipe_down_col[i])  
    end
    pipes={}
    pipe_up_col={}
    pipe_down_col={}

    for i = 1, #enemy_col  do
        collider:remove(enemy_col[i])  
    end
    enemies={}
    enemy_col={}

    for i = 1, #bullets_col do
        collider:remove(bullets_col[i])  
    end
    bullets={}
    bullets_col={}

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

function destroy_enemy_if_dead()
    for i=#enemies, 1, -1 do
        e = enemies[i]
        if e.is_dead then
            collider:remove(enemy_col[i])
            table.remove(enemies,i)
            table.remove(enemy_col,i)
        end
    end
end

function destroy_bullet(i)
    collider:remove(bullets_col[i]) 
    table.remove(bullets, i)
    table.remove(bullets_col, i)
end

function checking_player_collisions()
    for other, delta in pairs(collider:collisions(player_col)) do
        local t1 = player_col.object_type
        local t2 = other.object_type
    
        if (t1 == "player" and (t2 == "pipe" or t2 == "enemy")) then
            game.state.running = false
            game.state.ended = true
        end
    end

    for i = #bullets_col, 1, -1 do
        local bullet = bullets_col[i]
        local b = bullets[i]
        for other, delta in pairs(collider:collisions(bullet)) do
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
end

function move_to_for_pipes()
    for i = 1, #pipe_up_col  do
        pipe_up_col[i]:moveTo(pipes[i].pos.x, pipes[i].pos.y - pipes[i].gap/2 - pipes[i].height/2)
        pipe_down_col[i]:moveTo(pipes[i].pos.x, pipes[i].pos.y + pipes[i].gap/2 + pipes[i].height/2)
    end
end

function move_to_for_bullets()
    for i = 1, #bullets_col  do
        bullets_col[i]:moveTo(bullets[i].pos.x,bullets[i].pos.y)
    end
end

function move_to_for_enemies()
    for i = 1, #enemy_col  do
        enemy_col[i]:moveTo(enemies[i].pos.x,enemies[i].pos.y)
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
        local new_up_col = collider:rectangle(new_pipe.pos.x - new_pipe.width/2, new_pipe.pos.y - new_pipe.gap/2 - new_pipe.height, new_pipe.width, new_pipe.height)
        local new_down_col = collider:rectangle(new_pipe.pos.x - new_pipe.width/2, new_pipe.pos.y + new_pipe.gap/2, new_pipe.width, new_pipe.height)
        table.insert(pipes, new_pipe)
        table.insert(pipe_up_col, new_up_col)
        table.insert(pipe_down_col, new_down_col)
        new_up_col.object_type = "pipe"
        new_down_col.object_type = "pipe"
    end)

    given_timer:every(5, function()
        local new_enemy = newEnemy()
        local new_enemy_col=collider:circle(new_enemy.pos.x, new_enemy.pos.y,new_enemy.r)
        table.insert(enemies, new_enemy)
        table.insert(enemy_col, new_enemy_col)
        new_enemy_col.object_type="enemy"
        new_enemy_col.parent = new_enemy
    end)

end
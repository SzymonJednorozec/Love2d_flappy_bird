local love = require "love"
utils = require "utils"
SFX = require "SFX"
local Vector = require "vector"
local newPlayer = require "player"
local newPipe = require "pipe"
local newBullet = require "bullet"
local Timer = require "timer"
local newEnemy = require "enemy_basic"
local newSpecialEnemy = require "enemy_special"
local newImmortal = require "enemy_immortal"
local newCoin = require "coin"
local particles = require "particles"

local Menu = require "menu"

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
local highScore = 0
local level = 7
local lvl = 1

local background = utils.loadSprite("sprites/background_ai_image.png")

local is_immortal_spawned = false

local mouse 

local game = {
    state = {
        menu=true,
        paused=false,
        running=false,
        ended=false
    }
}

-------------------------------------------------load
function love.load()
    screen_width, screen_height = love.graphics.getDimensions()
    player = newPlayer()
    player_col = collider:circle(player.pos.x, player.pos.y, player.r)
    player_col.object_type="player"
    set_timer(pipe_timer)
    particles.load()
    highScore = utils.loadHighScore()
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
        checking_highscore()
        local mx, my = love.mouse.getPosition()
        mouse = Vector(mx,my)
        player:move(mouse,dt)
        --enemies bullets coins
        for _, e in ipairs(enemies) do e:move(player.pos,dt) end
        destroy_enemy_if_dead()
        for _, b in ipairs(bullets) do b:move(dt) end
        for _, c in ipairs(coins) do c:move(dt) end
        --level
        menaging_lv()
        --colliders
        player_col:moveTo(player.pos.x, player.pos.y)
        checking_all_collisions()
        player_out_of_boundaries()
        bullets_out_of_boundaries()
    end
    particles.update(dt)

end
-------------------------------------------------draw
function love.draw()
    --menu
    if game.state.menu then
        Menu.drawMenu(background)
    end
    --running
    if game.state.running then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.draw(background.image,0,0,0,screen_width/background.width,screen_height/background.height)
        love.graphics.printf("Points: " .. score,love.graphics.newFont(20),30,30,screen_width)
        love.graphics.printf("lvl: " .. lvl,love.graphics.newFont(20),230,30,screen_width)
        love.graphics.printf("level: " .. level,love.graphics.newFont(20),430,30,screen_width)
        love.graphics.printf("highscore: " .. highScore,love.graphics.newFont(20),630,30,screen_width)
        player:draw()
        particles.draw()
        for _, p in ipairs(pipes) do p:draw() end
        for _, e in ipairs(enemies) do e:draw() end
        for _, b in ipairs(bullets) do b:draw() end
        for _, c in ipairs(coins) do c:draw() end
    end
end
-----------------------------------------------functions

function love.keypressed(key, scancode, isrepeat)
    if game.state.running then
        if key == "space" then
            SFX.play("shoot")
            player.jump=true
            local new_bullet = newBullet(collider,player.pos:clone(),(mouse - player.pos):normalized())
            table.insert(bullets,new_bullet)
        end
    end
    if game.state.menu then
        Menu.keypressed(key)
        if key == "space" then
            game.state.running=true
            game.state.menu=false
            reset_everything()
            Menu.gamerunning()
        end
    end
 end


function reset_everything()

    player.pos=Vector(400,400)
    player.vel=Vector(0,-300)
    collider:remove(player_col)

    for i = 1, #pipes  do
        pipes[i].destroyed=true
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
        coins[i].destroyed=true
        collider:remove(coins[i].collider)  
    end
    coins={}

    score=0
    level=1
    lvl=1
    is_immortal_spawned = false

    player_col = collider:circle(player.pos.x, player.pos.y, player.r)
    player_col.object_type="player"

    pipe_timer = Timer.new()
    set_timer(pipe_timer)
end

function player_out_of_boundaries()
    if player.pos.x<0 or player.pos.x>screen_width or player.pos.y<0 or player.pos.y>screen_height then
        player_dead()
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
    SFX.play("explosion1")
    coins[i].destroyed=true
    collider:remove(coins[i].collider)
    table.remove(coins,i)
end

function pickup_coin(i)
    SFX.play("coin")
    score=score+coins[i].value
    coins[i].destroyed=true
    collider:remove(coins[i].collider)
    table.remove(coins,i)
end

function destroy_enemy_if_dead()
    for i=#enemies, 1, -1 do
        e = enemies[i]
        if e.is_dead then
            particles.spawn("explode",e.pos.x,e.pos.y)
            local new_coin = newCoin(collider,e.pos,level)
            move_up(new_coin,2,70)
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

function player_dead()
    SFX.play("dead")
    Menu.menurunning()
    game.state.running = false
    game.state.menu = true
end

function checking_highscore()
    if score > highScore then
        highScore = score
        utils.saveHighScore(highScore)
    end
end

---------------------------------------------------------------------Checking collisions
function checking_all_collisions()
    for other, delta in pairs(collider:collisions(player_col)) do
        local t1 = player_col.object_type
        local t2 = other.object_type
    
        if (t1 == "player" and (t2 == "pipe" or t2 == "enemy")) then
            player_dead()
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
        if pipes[i].x < player.pos.x - 25 then
            SFX.play("score")
            pipes[i].destroyed = true
            particles.spawn("up_pipe",pipes[i].x,pipes[i].y+pipes[i].gap/2+pipes[i].height/2)
            particles.spawn("down_pipe",pipes[i].x,pipes[i].y-pipes[i].gap/2-pipes[i].height/2)
            collider:remove(pipes[i].collider1) 
            collider:remove(pipes[i].collider2)  
            table.remove(pipes, i)

            score = score + 1
            lvl = lvl + 1
        end
    end
end


function spawn_enemy(number)
    for i=1, number do
        local enemy = newEnemy(collider,level)
        table.insert(enemies, enemy)
    end
    if level>=4 and is_immortal_spawned == false then
        local enemy = newImmortal(collider,level)
        table.insert(enemies, enemy)
        is_immortal_spawned=true
    end
end

function spawn_special_enemy(number)
    for i=1, number do
        local enemy = newSpecialEnemy(collider,level)
        table.insert(enemies, enemy)
    end
end

local number_of_enemies = {1,1,1,1,1,2,2}
local number_of_special_enemies = {0,0,1,1,2,2,2}
function set_timer(given_timer)
    given_timer:every(3, function()
        local new_pipe = newPipe(collider,level)
        if new_pipe.is_tweening then move_up(new_pipe,1,100) end
        table.insert(pipes, new_pipe)
    end)

    given_timer:every(9, function()
        spawn_enemy(number_of_enemies[level])
        spawn_special_enemy(number_of_special_enemies[level])
    end)

end

-----------------------------------------------Tween functions

function move_up(object,time,offset)
    if object.destroyed then return end
    local new_pos = object.y - offset
    tween_timer:tween(time, object, { y = new_pos }, 'in-out-sine', function()
        move_down(object,time,offset)
    end)
end

function move_down(object,time,offset)
    if object.destroyed then return end
    local new_pos = object.y + offset
    tween_timer:tween(time, object, { y = new_pos }, 'in-out-sine', function()
        move_up(object,time,offset)
    end)
end

function menaging_lv()
    level = math.min(math.ceil(lvl / 25.0),7)
end
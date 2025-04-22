local love = require "love"
local Vector = require "vector"

local function random_pose()
    local side = love.math.random(2,4)  --for now they will not spawn over the player
    local x,y = 0,0
    if side == 1 then --up
        x = love.math.random(0,screen_width)
        y = -100
    elseif side == 2 then --down
        x = love.math.random(0,screen_width)
        y = screen_height + 100
    elseif side == 3 then --left
        x = -100
        y = love.math.random(0,screen_height)
    elseif side == 4 then --right
        x = screen_width+100
        y = love.math.random(0,screen_height)
    end
    return x,y
end

local function new(collider, lvl)
    local enemy = {
        pos = Vector(random_pose()),
        vel = Vector(0, 0),
        dangermark_pos = Vector(0,0),
        r = 30,
        acceleration = 6,
        max_speed = 50,
        
        hp = 1,
        is_dead = false,

        knockback_time = 0,
        knockback_decay = 0.96,
        sprite = utils.loadSprite("sprites/immortal_enemy.png"),
        dsprite = utils.loadSprite("sprites/exclamation_mark.png")
    }

    enemy.collider = collider:circle(enemy.pos.x, enemy.pos.y, enemy.r)
    enemy.collider.object_type = "enemy" 
    enemy.collider.parent = enemy

    -- Metody
    enemy.move = function(self, player_pos, dt)
        if self.knockback_time > 0 then
            self.knockback_time = self.knockback_time - dt
            self.vel = self.vel * self.knockback_decay
        else
            local direction = (player_pos - self.pos):normalized()
            self.vel = self.vel + direction * self.acceleration
            if self.vel:len() > self.max_speed then
                self.vel = direction * self.max_speed
            end
        end

        self.pos = self.pos + self.vel * dt
        self.collider:moveTo(self.pos.x, self.pos.y)
        self:dangermark_update()
    end

    enemy.draw = function(self)
        love.graphics.setColor(1, 0, 0)
        -- love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.sprite.image, self.pos.x, self.pos.y, self.angle, self.r*2.5/self.sprite.width, self.r*2.5/self.sprite.height, self.sprite.width / 2, self.sprite.height / 2)
        love.graphics.draw(self.dsprite.image, self.dangermark_pos.x, self.dangermark_pos.y, 0, self.r/self.dsprite.width, self.r*1.5/self.dsprite.height, self.dsprite.width / 2, self.dsprite.height / 2)
        -- love.graphics.circle("fill", self.dangermark_pos.x, self.dangermark_pos.y, self.r)
    end

    enemy.getHit = function(self, direction, damage)
        SFX.play("hit")
        self.vel = direction * 700 
        self.knockback_time = 1
    end

    enemy.dangermark_update = function(self)
        local margin = 25 -- odległość od krawędzi ekranu
        local x, y = self.pos.x, self.pos.y
    
        -- Jeśli wróg jest wewnątrz ekranu, chowamy wskaźnik
        if x >= 0 and x <= screen_width and y >= 0 and y <= screen_height then
            self.dangermark_pos = Vector(-300, -300)
            return
        end
    
        -- Oblicz kierunek od środka ekranu do wroga
        local center = Vector(screen_width / 2, screen_height / 2)
        local direction = (self.pos - center):normalized()
    
        -- Znajdź punkt przecięcia z krawędzią ekranu
        local dx, dy = direction.x, direction.y
        local px, py = center.x, center.y
    
        local scale_x = dx > 0 and (screen_width - margin - px) / dx or (margin - px) / dx
        local scale_y = dy > 0 and (screen_height - margin - py) / dy or (margin - py) / dy
    
        local scale = math.min(math.abs(scale_x), math.abs(scale_y))
    
        local mark_x = px + dx * scale
        local mark_y = py + dy * scale
    
        self.dangermark_pos = Vector(mark_x, mark_y)
    end

    return enemy
end

return new

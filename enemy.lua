local Vector = require "vector"

local function new(collider)
    local enemy = {
        pos = Vector(1500, 400),
        vel = Vector(0, 0),
        r = 30,
        acceleration = 10,
        max_speed = 300,
        
        hp = 2,
        is_dead = false,

        knockback_time = 0,
        knockback_decay = 0.9,
    }

    -- Dodaj collider i przypisz do enemy
    enemy.collider = collider:circle(enemy.pos.x, enemy.pos.y, enemy.r)
    enemy.collider.object_type = "enemy" -- przydatne przy kolizjach
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
        self.collider:moveTo(self.pos.x, self.pos.y) -- aktualizuj pozycję collidera
    end

    enemy.draw = function(self)
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
    end

    enemy.getHit = function(self, direction, damage)
        self.hp = self.hp - damage
        if self.hp < 1 then
            self.is_dead = true
        else
            self.vel = direction * 300 
            self.knockback_time = 0.2
        end
    end

    return enemy
end

return new

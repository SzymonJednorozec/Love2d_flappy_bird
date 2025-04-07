local Vector = require "vector"

local function new()
    return {
        pos = Vector(1500, 400),
        vel = Vector(0, 0),
        r = 30,
        acceleration = 10,
        max_speed = 300,
        hp = 2,
        is_dead = false,

        knockback_time = 0,
        knockback_decay = 0.9,

        move = function(self, player_pos, dt)
            if self.knockback_time > 0 then
                self.knockback_time = self.knockback_time - dt
                self.vel = self.vel * self.knockback_decay
                self.pos = self.pos + self.vel * dt
            else
                local direction = (player_pos - self.pos):normalized()
                self.vel = self.vel + direction * self.acceleration
                if self.vel:len() > self.max_speed then
                    self.vel = direction * self.max_speed
                end
                self.pos = self.pos + self.vel * dt
            end
        end,

        draw = function(self)
            love.graphics.setColor(1, 0, 0)
            love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
        end,

        getHit = function(self, direction, damage)
            self.hp = self.hp - damage
            if self.hp < 1 then
                self.is_dead = true
            else
                self.vel = direction * 300 
                self.knockback_time = 0.2 -- czas trwania knockbacku w sekundach
            end
        end
    }
end

return new

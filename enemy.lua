local Vector = require "vector"

local function new()
    return {
        pos = Vector(1200, 400),
        vel = Vector(0, 0),
        r = 30,
        acceleration = 10,
        max_speed = 200,

        move = function(self, player, dt)
            local direction = (player - self.pos):normalized()
            self.vel = self.vel + direction * self.acceleration
            if self.vel:len() > self.max_speed then
                self.vel = direction * self.max_speed
            end
            self.pos = self.pos + self.vel * dt
        end,

        draw = function(self)
            love.graphics.setColor(1, 0, 0)
            love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
        end
    }
end

return new
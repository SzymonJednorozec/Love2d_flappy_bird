local Vector = require "vector"

local function new()
    return {
        pos = Vector(400, 400),
        vel = Vector(0, 0),
        r = 30,
        jumpheight = 400,
        jump = false,

        move = function(self, mouse, dt)
            self.vel.y = self.vel.y + 600 * dt
            local direction = (self.pos - mouse):normalized()

            if self.jump then
                self.vel = direction * self.jumpheight
                self.jump = false
            end

            self.pos = self.pos + self.vel * dt
        end,

        draw = function(self)
            love.graphics.setColor(0.3, 0.3, 0.5)
            love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
        end
    }
end

return new
local Vector = require "vector"

local function new(enemy_pos)
    return {
        x = 500,
        y = 500,
        r = 7,
        speed = 75,

        move = function(self,dt)
            self.x = self.x - self.speed * dt 
        end,

        draw = function(self)
            love.graphics.setColor(0, 1, 0)
            love.graphics.circle("fill", self.x, self.y, self.r)
        end
    }
end

return new
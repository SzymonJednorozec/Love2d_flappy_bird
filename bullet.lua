local Vector = require "vector"

local function new(player_pos,direction)
    local offset = 50
    return {
        direction=direction,
        pos = player_pos:clone() + direction * offset,
        r = 10,
        speed = 400,

        move = function(self,dt)
            self.pos = self.pos + self.direction * self.speed * dt
        end,

        draw = function(self)
            love.graphics.setColor(0, 1, 0)
            love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
        end
    }
end

return new
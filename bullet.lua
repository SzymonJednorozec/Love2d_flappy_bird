local Vector = require "vector"

local function new(collider,player_pos,direction)
    local offset = 50
    local bullet =  {
        direction=direction,
        pos = player_pos:clone() + direction * offset,
        r = 10,
        speed = 400
    }

    bullet.collider = collider:circle(bullet.pos.x, bullet.pos.y, bullet.r)
    bullet.collider.object_type = "bullet" 
    bullet.collider.parent = bullet

    bullet.move = function(self,dt)
        self.pos = self.pos + self.direction * self.speed * dt
        self.collider:moveTo(self.pos.x,self.pos.y)
    end

    bullet.draw = function(self)
        love.graphics.setColor(0, 1, 0)
        love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
    end
    return bullet
end

return new
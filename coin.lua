local Vector = require "vector"

local function new(collider,enemy_pos)
    local coin = {
        x = enemy_pos.x,
        y = enemy_pos.y,
        r = 7,
        speed = 75,
    }

    coin.collider = collider:circle(coin.x,coin.y,coin.r)
    coin.collider.object_type = "coin"
    coin.collider.parent = coin

    coin.move = function(self,dt)
        self.x = self.x - self.speed * dt 
        self.collider:moveTo(self.x,self.y)
    end

    coin.draw = function(self)
        love.graphics.setColor(0, 1, 0)
        love.graphics.circle("fill", self.x, self.y, self.r)
    end
    return coin
end

return new
local Vector = require "vector"

local function new(collider,enemy_pos,lvl)
    local coin_value = {2,2,3,4,5,5,6}
    local coin = {
        is_destroyed=false,
        x = enemy_pos.x,
        y = enemy_pos.y,
        r = 10,
        speed = 75,
        value = coin_value[lvl],
        sprite = utils.loadSprite("sprites/coin.png")
    }

    coin.collider = collider:circle(coin.x,coin.y,coin.r)
    coin.collider.object_type = "coin"
    coin.collider.parent = coin

    coin.move = function(self,dt)
        self.x = self.x - self.speed * dt 
        self.collider:moveTo(self.x,self.y)
    end

    coin.draw = function(self)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.sprite.image, self.x, self.y, 0, self.r*2/self.sprite.width, self.r*2/self.sprite.height, self.sprite.width / 2, self.sprite.height / 2)
    end
    return coin
end

return new
local Vector = require "vector"

local function new(collider,player_pos,direction)
    local offset = 50
    local bullet =  {
        direction=direction,
        pos = player_pos:clone() + direction * offset,
        r = 10,
        speed = 400,
        sprite = utils.loadSprite("sprites/bullet.png")
    }

    bullet.collider = collider:circle(bullet.pos.x, bullet.pos.y, bullet.r)
    bullet.collider.object_type = "bullet" 
    bullet.collider.parent = bullet

    bullet.move = function(self,dt)
        self.pos = self.pos + self.direction * self.speed * dt
        self.collider:moveTo(self.pos.x,self.pos.y)
    end

    bullet.draw = function(self)
        -- love.graphics.setColor(0, 1, 0)
        -- love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.sprite.image, self.pos.x, self.pos.y, 0, self.r*2/self.sprite.width, self.r*2/self.sprite.height, self.sprite.width / 2, self.sprite.height / 2)
    end
    return bullet
end

return new
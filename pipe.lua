local Vector = require "vector"

local function new()
    return{
        pos = Vector(screen_width+100,math.random((screen_height/2)-200,(screen_height/2)+200)),
        gap=400,
        width=75,
        height=800,
        r=50,
        speed=200,

        move = function(self,dt)
            self.pos.x = self.pos.x - self.speed * dt 
        end,

        draw = function(self)
            love.graphics.setColor(0.1, 0.3, 0.3)
            love.graphics.rectangle("fill", self.pos.x - self.width/2, self.pos.y + self.gap/2, self.width, self.height)
            love.graphics.rectangle("fill", self.pos.x - self.width/2, self.pos.y - self.gap/2 - self.height, self.width, self.height)
            --love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
        end,

        check_collision = function(player_pos,player_r)
            
        end
    }
end

return new
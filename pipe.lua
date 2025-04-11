local Vector = require "vector"

local function new(collider)
    local pipe = {
        pos = Vector(screen_width+100,math.random((screen_height/2)-200,(screen_height/2)+200)),
        gap=400,
        width=75,
        height=800,
        r=50,
        speed=200
    }

    pipe.collider1 = collider:rectangle(pipe.pos.x - pipe.width/2, pipe.pos.y - pipe.gap/2 - pipe.height, pipe.width, pipe.height) --up pipe
    pipe.collider2 = collider:rectangle(pipe.pos.x - pipe.width/2, pipe.pos.y + pipe.gap/2, pipe.width, pipe.height) --down pipe
    pipe.collider1.object_type = "pipe"
    pipe.collider1.parent = pipe
    pipe.collider2.object_type = "pipe"
    pipe.collider2.parent = pipe

    pipe.move = function(self,dt)
        self.pos.x = self.pos.x - self.speed * dt 
        self.collider1:moveTo(pipe.pos.x, pipe.pos.y - pipe.gap/2 - pipe.height/2)
        self.collider2:moveTo(pipe.pos.x, pipe.pos.y + pipe.gap/2 + pipe.height/2)
    end

    pipe.draw = function(self)
        love.graphics.setColor(0.1, 0.3, 0.3)
        love.graphics.rectangle("fill", self.pos.x - self.width/2, self.pos.y + self.gap/2, self.width, self.height)
        love.graphics.rectangle("fill", self.pos.x - self.width/2, self.pos.y - self.gap/2 - self.height, self.width, self.height)
        --love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
    end
            
        
    return pipe
end

return new
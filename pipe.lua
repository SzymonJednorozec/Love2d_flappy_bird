local Vector = require "vector"

local function new(collider,lvl)
    local pipe_tween = {false,false,false,false,false,true,true}
    local pipe_gap = {500,475,450,425,400,375,375}

    local pipe = {
        destroyed=false,
        x=screen_width+100,
        y=math.random((screen_height/2)-200,(screen_height/2)+200),
        gap=pipe_gap[lvl],
        width=80,
        height=800,
        r=50,
        speed=200,
        is_tweening = pipe_tween[lvl],
        sprite = utils.loadSprite("sprites/pipe.png")
    }

    pipe.collider1 = collider:rectangle(pipe.x - pipe.width/2, pipe.y - pipe.gap/2 - pipe.height, pipe.width, pipe.height) --up pipe
    pipe.collider2 = collider:rectangle(pipe.x - pipe.width/2, pipe.y + pipe.gap/2, pipe.width, pipe.height) --down pipe
    pipe.collider1.object_type = "pipe"
    pipe.collider1.parent = pipe
    pipe.collider2.object_type = "pipe"
    pipe.collider2.parent = pipe

    pipe.move = function(self,dt)
        self.x = self.x - self.speed * dt 
        self.collider1:moveTo(pipe.x, pipe.y - pipe.gap/2 - pipe.height/2)
        self.collider2:moveTo(pipe.x, pipe.y + pipe.gap/2 + pipe.height/2)
    end

    pipe.draw = function(self)
        love.graphics.setColor(0.1, 0.3, 0.3)
        love.graphics.setColor(1, 1, 1)
        -- love.graphics.rectangle("fill", self.x - self.width/2, self.y + self.gap/2, self.width, self.height)
        -- love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.gap/2 - self.height, self.width, self.height)
        love.graphics.draw(self.sprite.image,self.x, self.y + self.gap/2 + self.height/2,0,self.width/self.sprite.width,self.height/self.sprite.height,self.sprite.width / 2, self.sprite.height / 2)
        love.graphics.draw(self.sprite.image,self.x, self.y - self.gap/2 - self.height/2,math.pi,self.width/self.sprite.width,self.height/self.sprite.height,self.sprite.width / 2, self.sprite.height / 2)
        --love.graphics.circle("fill", self.x, self.y, self.r)
    end
            
        
    return pipe
end

return new
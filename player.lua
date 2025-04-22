local Vector = require "vector"

local function new()
    return {
        pos = Vector(400, 400),
        vel = Vector(0, -300),
        angle = 0,
        gun_pos = Vector(pos),
        gun_angle=0,
        r = 30,
        jumpheight = 400,
        jump = false,
        sprite = utils.loadSprite("sprites/player.png"),
        gun_sprite = utils.loadSprite("sprites/gun.png"),
        move = function(self, mouse, dt)
            self.vel.y = self.vel.y + 600 * dt
            local direction = (self.pos - mouse):normalized()

            if self.jump then
                self.vel = direction * self.jumpheight
                self.jump = false
                self.angle = math.rad(math.min(math.max(self.vel.x * 0.1, -30), 30))
            end
            self.angle = self.lerp(self.angle,0,0.01)
            local dx = mouse.x - self.pos.x
            local dy = mouse.y - self.pos.y
            self.gun_angle = math.atan2(dy, dx)
            self.pos = self.pos + self.vel * dt
            
            self.gun_pos.x = self.lerp(self.gun_pos.x,self.pos.x,0.7)
            self.gun_pos.y = self.lerp(self.gun_pos.y,self.pos.y+10,0.7)
        end,

        draw = function(self)
            -- love.graphics.setColor(0.3, 0.3, 0.5)
            -- love.graphics.circle("fill", self.pos.x, self.pos.y, self.r)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(self.sprite.image, self.pos.x, self.pos.y, self.angle, self.r*2.5/self.sprite.width, self.r*2.5/self.sprite.height, self.sprite.width / 2, self.sprite.height / 2)
            love.graphics.draw(self.gun_sprite.image, self.gun_pos.x, self.gun_pos.y, self.gun_angle + math.pi/2, self.r*1.5/self.gun_sprite.width, self.r*1.5/self.gun_sprite.height, self.gun_sprite.width / 2, self.gun_sprite.height / 2)
        end,

        lerp = function(a, b, t)
            return a + (b - a) * t
        end
        
    }
end

return new
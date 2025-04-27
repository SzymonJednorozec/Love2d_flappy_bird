local particles = {}
particles.effects = {}       
particles.instances = {}      

function particles.load() 
    local image = love.graphics.newImage("sprites/9_pixel.png")

    local up = love.graphics.newParticleSystem(image, 1000)

    up:setColors(
    255, 255, 0, 255,       
    255, 255, 0, 255,   
    255, 255, 0, 255    
    )
    up:setParticleLifetime(1.75)
    up:setEmissionArea("uniform", 40, 400)
    up:setSpeed(100)
    up:setRadialAcceleration(0, 0)
    up:setLinearDamping(0)
    up:setDirection(1.48)
    up:setSpread(0.08)
    up:setSizes(1.0, 1.0, 0.3)
    up:setSizeVariation(0.0)
    up:setSpin(1.0)
    up:setTangentialAcceleration(0)

    particles.effects["up_pipe"] = up

    local down = up:clone()
    down:setDirection(4.87)

    particles.effects["down_pipe"] = down

    local explode = love.graphics.newParticleSystem(image, 1000)

    explode:setColors(
    255, 0, 0, 255,      
    255, 165, 0, 255,   
    255, 255, 0, 255    
    )

    explode:setEmissionRate(0.00)
    explode:setParticleLifetime(0.2)
    explode:setEmissionArea("uniform", 5.00, 5.00)
    explode:setSpeed(110.00)
    explode:setRadialAcceleration(0, 120.00)
    explode:setLinearDamping(0.00)
    explode:setDirection(0.73)
    explode:setSpread(6.28)
    explode:setSizes(1.00, 3.00, 0.10)
    explode:setSizeVariation(0.00)
    explode:setSpin(1.00)
    explode:setTangentialAcceleration(0.00)

    particles.effects["explode"] = explode
end

function particles.spawn(name, x, y)
    local base = particles.effects[name]
    if not base then return end

    local p = base:clone()
    p:setPosition(x, y)
    p:emit(1000)
    table.insert(particles.instances, p)
end

function particles.update(dt)
    for i = #particles.instances, 1, -1 do
        local p = particles.instances[i]
        p:update(dt)

        if p:getCount() == 0 then
            table.remove(particles.instances, i)
        end
    end
end

function particles.draw()
    for _, p in ipairs(particles.instances) do
        love.graphics.draw(p)
    end
end

return particles

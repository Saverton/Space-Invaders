Bullet = Class{}

function Bullet:init(x, y, spd)
    self.width = 1
    self.height = 4
    
    self.x = x
    self.y = y

    self.dy = spd
end

function Bullet:update(dt)
    self.y = self.y + self.dy * dt
end

function Bullet:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
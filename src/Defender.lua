Defender = Class{}

function Defender:init(x, y, angle, da)
    self.angle = angle
    self.dim = 16
    self.x = x + 50 * math.cos(math.rad(self.angle)) - self.dim / 2
    self.y = y + 50 * math.sin(math.rad(self.angle)) - self.dim / 2
    self.da = da
end

function Defender:update(dt, x, y, da)
    self.angle = self.angle + self.da * dt
    self.da = da
    self.x = x + 50 * math.cos(math.rad(self.angle)) - self.dim / 2
    self.y = y + 50 * math.sin(math.rad(self.angle)) - self.dim / 2
end

function Defender:render()
    love.graphics.draw(gTextures['final'], gFrames['defender'][1], self.x, self.y)
end
Parachute = Class {}

local MAX_SWING_ANGLE = 10

function Parachute:init(x, y)
    self.type = 'parachute'
    self.x = x
    self.y = y
    self.angle = 0 -- swings back and forth
    self.width = 16
    self.height = 16
    self.dx = math.random(-10, 10)
    self.dy = 25
    self.dAngle = 20
end

function Parachute:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    self.angle = self.angle + self.dAngle * dt
    if math.abs(self.angle) > MAX_SWING_ANGLE then
        self.dAngle = self.dAngle * -1
    end
end

function Parachute:render()
    local orientation = math.rad(self.angle)
    love.graphics.draw(gTextures['parachute'], self.x, self.y, orientation)
end

function Parachute:shouldDespawn()
    return self.y + self.height > VIRTUAL_HEIGHT
end
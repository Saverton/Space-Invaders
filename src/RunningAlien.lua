RunningAlien = Class {}

function RunningAlien:init(x, y)
    self.type = 'running_alien'
    self.x = x
    self.y = y
    self.width = 2
    self.height = 5
    self.dx = 80 * (math.random(2) == 1 and 1 or -1) -- randomly positive or negative
    self.isAlive = true
end

function RunningAlien:update(dt, player)
    if self.isAlive == false then return end

    self.x = self.x + self.dx * dt

    -- chance to turn around increases as they get closer to player
    local playerXCenter = player.x + player.width / 2
    local distanceFromPlayer = math.abs(self.x - playerXCenter)
    if math.random(math.floor(distanceFromPlayer)) == 1 then
        if self.x < playerXCenter and self.dx > 0 then
            self.dx = self.dx * -1
        elseif self.x > playerXCenter and self.dx < 0 then
            self.dx = self.dx * -1
        end
    end
    
    if DidCollide(self, player) then
        self.isAlive = false
    end
end

function RunningAlien:render()
    if self.isAlive then
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    else
        love.graphics.rectangle('fill', self.x, self.y + (self.height - self.width), self.height, self.width)
    end
end

function RunningAlien:shouldDespawn()
    return self.x - self.width < 0 or self.x > VIRTUAL_WIDTH
end
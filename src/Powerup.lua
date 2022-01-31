--[[
    Class to define a powerup object. there are two possible powerup objects in this demo, the multiball powerup (which spawns 2 extra
    balls for the remainder of the current level) and the key powerup (which enables the player to destroy key blocks).
]]

Powerup = Class{}

--type 1 = multiball, type 2 = key
function Powerup:init(x, y, type)
    self.x = x
    self.y = y
    self.dy = type == 1 and 60 or 50
    self.width = 16
    self.height = 16

    self.type = type
    self.active = true
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
end

function Powerup:render()
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type], self.x, self.y)
end
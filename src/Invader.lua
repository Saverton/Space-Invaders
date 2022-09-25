Invader = Class{}

function Invader:init(type, x, y)
    self.type = type
    self.x = x
    self.y = y
    self.width = 16
    self.height = 16
end

function Invader:render()
    love.graphics.draw(gTextures['invaders'], gFrames['invaders'][self.type], self.x, self.y)
end

function Invader:intro(x, y)
    love.graphics.draw(gTextures['invaders'], gFrames['invaders'][self.type], x, y)
end

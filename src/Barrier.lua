Barrier = Class{}

function Barrier:init(x, y)
    self.x = x
    self.y = y
    self.dim = 5
end

function Barrier:render()
    love.graphics.rectangle("fill", self.x, self.y, self.dim, self.dim)
end
Cover = Class{}

function Cover:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self:generateCover()
end

function Cover:generateCover()
    self.cover = {}

    for y = 0, self.height - 1 do
        self.cover[y] = {}
        for x = 0, self.width - 1 do
            self.cover[y][x] = Barrier(self.x + x * 5, self.y + y * 5)
        end
    end
end

function Cover:update(dt)
end

function Cover:render(num)
    local show = num or 0
    local count = 0
    for k, row in pairs(self.cover) do
        for j, barrier in pairs(row) do
            if count >= show then
                barrier:render()
            end
            count = count + 1
        end
    end
end
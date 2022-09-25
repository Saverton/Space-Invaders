Fleet = Class{}

function Fleet:init(level)
    self.bullets = {}
    self.defeated = false
    self.explosions = {}

    if level % 12 == 0 then
        self.bossLevel = true
        self.boss = Boss()
        Timer.every(0.5, function()
            if gStateMachine.currentName == 'play' and not self.boss.exploding then
                if math.random(1 + 1 * self.boss.numDefenders) == 1  and #self.bullets < 10 then
                    table.insert(self.bullets, Bullet(self.boss.x + self.boss.width / 2, self.boss.y + self.boss.height / 2, 100))
                    gSounds['invader_shoot']:stop()
                    gSounds['invader_shoot']:play()
                end
            end
            if self.boss.exploding and self.boss.mode ~= 'd' then
                local px = math.random(32)
                local py = math.random(16)
                self.explosions = {}
                self:explode(self.boss.x + px, self.boss.y + py)
                gSounds['defeated']:stop()
                gSounds['defeated']:play()
            end
        end)
    else
        self.bossLevel = false
        self.rows = math.random(4, 7)
        self.columns = math.random(5, 10)
        self.x = 10
        self.y = 10
        self.width = self.columns * 26 - 10
        self.size = self.rows * self.columns
        self.tier = math.min(4, (level / 3 - (level % 3 / 3)) + 1)

        self:generateFleet()

        self.startingSpeed = math.min((-0.3 + (0.5 / (self.rows / 6.5)) + (0.5 / (self.columns / 9))) * math.pow(1.05, level), 5)
        self.dx = self.startingSpeed * 30
        self.dy = self.startingSpeed * 10
        self.mode = 'n'
        self.lastY = 10

        self.timer = 1
        self.time = 0
        self.step = 1
        
        Timer.every(1, function()
            for k, row in pairs(self.fleet) do
                for j, invader in pairs(row) do
                    if gStateMachine.currentName == 'play' then
                        if math.random(math.max(20, (100 - level * 5)) * (self.size / 40) * (2.5 - 0.5 * invader.type)) == 1 and #self.bullets < math.min(6, 1 + (level / 3)) then
                            table.insert(self.bullets, Bullet(invader.x + invader.width / 2, invader.y + invader.height, 100))
                            gSounds['invader_shoot']:stop()
                            gSounds['invader_shoot']:play()
                        end
                    end
                end
            end
        end)
    end
end

function Fleet:generateFleet()
    self.fleet = {}

    local rowType = {}
    for i = 1, self.rows do
        rowType[i] = math.random(self.tier)
    end

    for x = 0, self.columns - 1 do
        table.insert(self.fleet, {})
        for y = 0, self.rows - 1 do
            table.insert(self.fleet[x + 1], Invader(rowType[y + 1], self.x + x * 26, self.y + y * 20))
        end
    end
end

function Fleet:update(dt)
    if self.bossLevel then
        self.boss:update(dt)
    else
            --update fleet position
        if self.mode == 'h' then
            self.x = self.x + self.dx * dt
        elseif self.mode == 'v' then
            self.y = self.y + self.dy * dt
        end

        --check for when fleet reverses
        if self.mode == 'h' then
            if self.x < 10 then
                gSounds['invader_descends']:stop()
                gSounds['invader_descends']:play()
                self.mode = 'v'
                self.dx = self.dx * -1.1
                self.x = 10
            elseif self.x + self.width > VIRTUAL_WIDTH - 10 then
                gSounds['invader_descends']:stop()
                gSounds['invader_descends']:play()
                self.mode = 'v'
                self.dx = self.dx * -1.1
                self.x = VIRTUAL_WIDTH - 10 - self.width
            end
        elseif self.mode == 'v' and self.y > self.lastY + 10 then
            self.mode = 'h'
            self.y, self.lastY = self.lastY + 10, self.lastY + 10
            self.dy = self.dy * 1.1
            self.timer = math.abs(30 / self.dx)
        end

        --update invaders
        for k, column in pairs(self.fleet) do
            for j, invader in pairs(column) do
                invader.x = self.x + (k - 1) * 26
                invader.y = self.y + (j - 1) * 20
            end
        end

        --update timer
        self.time = self.time + dt
        if self.time >= self.timer and self.size > 0 then
            self.time = 0
            gSounds['invader_moves'][self.step % 2 + 1]:play()
            self.step = self.step + 1
        end
    end

    --update bullets
    for k, bullet in pairs(self.bullets) do
        if bullet.y > VIRTUAL_HEIGHT then
            table.remove(self.bullets, k)
        end
    end

    --update explosions
    for i in pairs(self.explosions) do
        local explosion = self.explosions[i]
        explosion:update(dt)
        if explosion:getCount() == 0 then
            table.remove(self.explosions, i)
        end
    end
end

function Fleet:condense()
    while true do
        if self:emptyColumn(1) then
            table.remove(self.fleet, 1)
            self.x = self.x + 26
        else
            break
        end
    end
    while true do
        if self:emptyColumn(#self.fleet) then
            table.remove(self.fleet, #self.fleet)
        else
            break
        end
    end
    self.width = #self.fleet * 26 - 10
end

function Fleet:emptyColumn(index)
    for i, invader in pairs(self.fleet[index]) do
        if invader ~= nil then
            return false
        end
    end
    return true
end

function Fleet:render()
    if self.bossLevel then
        self.boss:render()
    else
        for k, row in pairs(self.fleet) do
            for j, invader in pairs(row) do
                invader:render()
            end
        end
    end
    for i, bullet in pairs(self.bullets) do
        bullet:render()
    end
    for i in pairs(self.explosions) do
        love.graphics.draw(self.explosions[i], 0, 0)
    end
end

function Fleet:explode(x, y, n)
    local numParticles = n or 15
    local explosion = self:getExplosion(numParticles)
    explosion:setPosition(x, y)
    explosion:emit(numParticles)
    table.insert(self.explosions, explosion)
end

function Fleet:getExplosion(numParticles)
    local psystem = love.graphics.newParticleSystem(gTextures['particle'], numParticles)
    psystem:setLinearAcceleration(-40, -40, 40, 40)
    psystem:setParticleLifetime(0.5, 1)
    psystem:setEmissionArea('normal', 2, 2)
    return psystem
end
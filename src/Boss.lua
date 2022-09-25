Boss = Class{}

function Boss:init()
    gSounds['final-boss']:play()
    self.x = 50
    self.y = -50
    self.width = 32
    self.height = 16
    self.numDefenders = 20
    self:getDefenders()

    self.dx = 50
    self.dy = 10
    self.mode = 'n'
    self.lastY = 50

    Timer.after(20, function()
        gSounds['final-boss-loop']:setLooping(true)
        gSounds['final-boss-loop']:play()
    end)

    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 45)
    self.psystem:setLinearAcceleration(-30, 10, 30, 30)
    self.psystem:setParticleLifetime(0.5, 1)
    self.psystem:setEmissionArea('normal', 5, 5)

    self.exploding = false
end

function Boss:getDefenders()
    self.defenders = {}
    self.defenderDa = 360 / self.numDefenders
    for i = 1, self.numDefenders do
        self.defenders[i] = Defender(self.x + (self.width / 2), self.y + (self.height / 2), self.defenderDa * (i - 1), self.defenderDa)
    end
end

function Boss:update(dt)
    if self.mode == 'h' then
        self.x = self.x + self.dx * dt
        if self.x < 50 then
            self.x = 50
            self.mode = 'v'
            self.dx = self.dx * -1.1
            if self.numDefenders == 0 then
                self.dx = self.dx * 1.1
            end
            gSounds['invader_descends']:stop()
            gSounds['invader_descends']:play()
        elseif self.x > VIRTUAL_WIDTH - 50 - self.width then
            self.x = VIRTUAL_WIDTH - 50 - self.width
            self.mode = 'v'
            self.dx = self.dx * -1.1
            if self.numDefenders == 0 then
                self.dx = self.dx * 1.1
            end
            gSounds['invader_descends']:stop()
            gSounds['invader_descends']:play()
        end
    elseif self.mode == 'v' then
        self.y = self.y + self.dy * dt
        if self.y > self.lastY + 10 then
            self.y = self.lastY + 10
            self.lastY = self.y
            self.dy = self.dy * 1.1
            self.mode = 'h'
        end
    end

    self.defenderDa = math.min(360, 360 / self.numDefenders)
    

    for k, defender in pairs(self.defenders) do
        defender:update(dt, self.x + (self.width / 2), self.y + (self.height / 2), self.defenderDa)
    end
end

function Boss:render()
    if self.mode ~= 'd' then
        love.graphics.draw(gTextures['final'], gFrames['final_invader'][1], self.x, self.y)
    end
    for k, defender in pairs(self.defenders) do
        defender:render()
    end
end
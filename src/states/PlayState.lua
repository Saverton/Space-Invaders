PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.highScores = params.highScores
    
    self.level = params.level

    self.player = params.player

    self.fleet = params.fleet
    if self.level % 12 ~= 0 then
        self.fleet.mode = 'h'
        self.fleet.timer = math.abs(30 / self.fleet.dx)
    end

    self.score = params.score
    self.startingScore = params.score

    self.covers = params.covers
    self.paused = false
    self.pauseButton = Button(VIRTUAL_WIDTH / 2 - 5, 15, 8, 10, '||')

    self.over = false
    self.explosions = {}
end

function PlayState:update(dt)
    if not self.paused and not self.over then
        local deadBullets = {}
        local deadBulletsF = {}
        --detect collisions
        --player bullet on invader
        for i, bullet in pairs(self.player.bullets) do
            for k, cover in pairs(self.covers) do
                for j, row in pairs(cover.cover) do
                    for l, barrier in pairs(row) do
                        if self:collides(bullet.x, bullet.y, bullet.width, bullet.height, barrier.x, barrier.y, barrier.dim, barrier.dim) then
                            row[l] = nil
                            gSounds['cover_destroyed']:stop()
                            gSounds['cover_destroyed']:play()
                            table.insert(deadBullets, i)
                        end
                    end
                end
            end
            if self.fleet.bossLevel then
                if self:collides(
                    bullet.x, bullet.y, bullet.width, bullet.height, self.fleet.boss.x, self.fleet.boss.y, self.fleet.boss.width, self.fleet.boss.height
                ) and not self.fleet.boss.exploding then
                    if self.fleet.boss.numDefenders < 1 then
                        table.insert(deadBullets, i)
                        self.fleet.bullets = {}
                        gSounds['invader_dies']:stop()
                        gSounds['invader_dies']:play()
                        self.score = self.score + 1000
                        self.fleet.boss.exploding = true
                        self.fleet:explode(self.fleet.boss.x + 16, self.fleet.boss.y + 8)
                        self.fleet.boss.mode = 'n'
                        gSounds['final-boss-loop']:stop()
                        self:bossDies()
                    else
                        if #self.fleet.bullets < 10 then
                            table.insert(self.fleet.bullets, Bullet(bullet.x, bullet.y - 4, 100))
                        end
                        table.insert(deadBullets, i)
                        gSounds['reverse']:stop()
                        gSounds['reverse']:play()
                    end
                end
                for k, defender in pairs(self.fleet.boss.defenders) do
                    if self:collides(bullet.x, bullet.y, bullet.width, bullet.height, defender.x, defender.y, defender.dim, defender.dim) then
                        table.insert(deadBullets, i)
                        table.remove(self.fleet.boss.defenders, k)
                        self.fleet:explode(defender.x + 8, defender.y + 8)
                        self.fleet.boss.numDefenders = self.fleet.boss.numDefenders - 1
                        gSounds['invader_dies']:stop()
                        gSounds['invader_dies']:play()
                        self.score = self.score + 500
                    end
                end
            else
                for j, row in pairs(self.fleet.fleet) do
                    for k, invader in pairs(row) do
                        if self:collides(bullet.x, bullet.y, bullet.width, bullet.height, invader.x, invader.y, invader.width, invader.height) then
                            --remove invader, play invader death, remove bullet that hit invader.
                            self.fleet:explode(invader.x + 8, invader.y + 8)
                            self.fleet.size = self.fleet.size - 1
                            self.fleet.fleet[j][k] = nil
                            Timer.after(1.5, function()
                                --check for no more invaders
                                if self.fleet.size <= 0 and not self.fleet.defeated then
                                    self.fleet.defeated = true
                                    --no invaders left, game ends
                                    gStateMachine:change('advance', {
                                        highScores = self.highScores,
                                        level = self.level + 1,
                                        player = self.player,
                                        score = self.score,
                                        oldCover = self.covers
                                    })
                                end
                            end)
                            gSounds['invader_dies']:stop()
                            gSounds['invader_dies']:play()
                            table.insert(deadBullets, i)

                            --update player score
                            self.score = self.score + invader.type * 50
                            
                            --remove columns that are empty
                            if self.fleet.size > 0 then
                                self.fleet:condense()
                            end
                        end
                    end
                end
            end
        end
        --invader bullet on player
        for i, bullet in pairs(self.fleet.bullets) do
            bullet:update(dt)
            for k, cover in pairs(self.covers) do
                for j, row in pairs(cover.cover) do
                    for l, barrier in pairs(row) do
                        if self:collides(bullet.x, bullet.y, bullet.width, bullet.height, barrier.x, barrier.y, barrier.dim, barrier.dim) then
                            row[l] = nil
                            table.insert(deadBulletsF, i)
                            gSounds['cover_destroyed']:stop()
                            gSounds['cover_destroyed']:play()
                        end
                    end
                end
            end
            
            if self:collides(bullet.x, bullet.y, bullet.width, bullet.height, self.player.x, self.player.y, self.player.width, self.player.height) then
                self:defeated()
                gSounds['final-boss-loop']:stop()
            elseif bullet.y + bullet.height > VIRTUAL_HEIGHT then
                gSounds['efire_hits']:stop()
                gSounds['efire_hits']:play()
                table.insert(deadBulletsF, i)
            end
        end


        --check for lose state: invader position
        if self.fleet.bossLevel then
            for k, defender in pairs(self.fleet.boss.defenders) do
                if defender.y + defender.dim > VIRTUAL_HEIGHT - 50 and not self.over then
                    gSounds['final-boss-loop']:stop()
                    self:defeated()
                end
            end
            if self.fleet.boss.y + self.fleet.boss.height > VIRTUAL_HEIGHT - 50 and not self.over then
                gSounds['final-boss-loop']:stop()
                self:defeated()
            end
        else
            for j, row in pairs(self.fleet.fleet) do
                for k, invader in pairs(row) do
                    if invader.y + invader.height > VIRTUAL_HEIGHT - 50 and not self.over then
                        self:defeated()
                    end
                end
            end
        end

        --destroy dead bullets
        for k in pairs(deadBullets) do
            self.player.bullets[deadBullets[k]] = nil
        end
        for k in pairs(deadBulletsF) do
            self.fleet.bullets[deadBulletsF[k]] = nil
        end
    end
    
    if not self.paused then
        self.player:update(dt)
        self.fleet:update(dt)
        for i, explosion in pairs(self.explosions) do
            explosion:update(dt)
        end

        Timer.update(dt)
    end

    --pause/unpause game on key press 'p'
    if love.keyboard.wasPressed('p') or self.pauseButton:isPressed() then
        self.paused = not self.paused
        gSounds['pause']:play()
    end
    --exit game on escape
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    love.graphics.rectangle('fill', 0, VIRTUAL_HEIGHT - 50, VIRTUAL_WIDTH, 1)
    if not self.over then
        self.player:render()
    end
    self.fleet:render()
    for i, cover in pairs(self.covers) do
        cover:render()
    end
    for i in pairs(self.explosions) do
        love.graphics.draw(self.explosions[i], 0, 0)
    end

    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.printf('LVL ' .. tostring(self.level), 5, 5, VIRTUAL_WIDTH, 'left')
    love.graphics.printf('SCORE ' .. tostring(self.score), 50, 5, VIRTUAL_WIDTH, 'left')

    if self.paused then
        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 20, VIRTUAL_HEIGHT / 2 - 20, 40, 40)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 13, VIRTUAL_HEIGHT / 2 - 15, 10, 30)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 + 3, VIRTUAL_HEIGHT / 2 - 15, 10, 30)
        love.graphics.setFont(gFonts['medium'])
        love.graphics.printf('[PAUSED]', 0, VIRTUAL_HEIGHT / 2 + 25, VIRTUAL_WIDTH, 'center')
    end
    love.graphics.setFont(gFonts['small'])
    self.pauseButton:render()
end

function PlayState:collides(x1, y1, w1, h1, x2, y2, w2, h2)
    if x1 + w1 < x2 or x1 > x2 + w2 then
        return false
    end

    if y1 + h1 < y2 or y1 > y2 + h2 then
        return false
    end

    return true
end

function PlayState:exit() end

function PlayState:defeated()
    self.over = true
    gSounds['defeated']:play()
    self:explode(self.player.x + self.player.width / 2, self.player.y + self.player.height / 2, 45)
    self.player.bullets = {}
    self.fleet.bullets = {}
    if not self.fleet.bossLevel then
        self.fleet.dx = 0
        Timer.tween(1.25, {
            [self.fleet] = {y = -VIRTUAL_HEIGHT}
        })
    else
        self.fleet.boss.dx = 0
        Timer.tween(1.25, {
            [self.fleet.boss] = {y = -VIRTUAL_HEIGHT}
        })
    end
    Timer.after(1.5, function()
        if self.player.lives > 0 then
            self.player:reset()
            gStateMachine:change('advance', {
                highScores = self.highScores,
                level = self.level,
                player = self.player,
                score = self.startingScore,
                died = true,
                oldCover = self.covers
            })
        else
            gStateMachine:change('game-over', {
                highScores = self.highScores,
                score = self.score,
                fleet = self.fleet,
                level = self.level
            })
        end
    end)
end

function PlayState:bossDies()
    Timer.after(3, function()
        self.fleet.boss.mode = 'd'
        self.fleet:explode(self.fleet.boss.x + self.fleet.boss.width / 2, self.fleet.boss.y + self.fleet.boss.height / 2, 45)
        gSounds['defeated']:stop()
        gSounds['defeated']:play()
    end)

    Timer.after(4, function()
        if not self.fleet.defeated then
            self.fleet.defeated = true
            gStateMachine:change('advance', {
                highScores = self.highScores,
                level = self.level + 1,
                player = self.player,
                score = self.score,
                oldCover = self.cover
            })
        end
    end)
end

function PlayState:explode(x, y, n)
    local numOfParticles = 30 or n
    local explosion = self:getExplosion(numOfParticles)
    explosion:setPosition(x, y)
    explosion:emit(numOfParticles)
    table.insert(self.explosions, explosion)
end

function PlayState:getExplosion(n)
    local psystem = love.graphics.newParticleSystem(gTextures['particle'], n)
    psystem:setLinearAcceleration(-40, -40, 40, 40)
    psystem:setParticleLifetime(0.5, 1)
    psystem:setEmissionArea('normal', 2, 2)
    return psystem
end
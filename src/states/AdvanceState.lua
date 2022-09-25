AdvanceState = Class{__includes = BaseState}

function AdvanceState:enter(params)
    self.highScores = params.highScores

    self.level = params.level or 1

    self.player = params.player or Tank()

    self.fleet = Fleet(self.level)

    self.score = params.score or 0

    self.waitTime = self.fleet.bossLevel and 4 or 1

    self.levelY = -50

    self.player.bullets = {}

    self.alpha = 1

    self.covers = {}
    self.oldCover = params.oldCover or {}
    
    if not self.fleet.bossLevel then
        self.leftLine = -self.fleet.width
        self.rightLine = VIRTUAL_WIDTH
    end

    if params.fade_in then
        self.alpha = 0
        Timer.tween(1, {
            [self] = {alpha = 1}
        }):finish(function()
            self:intro()
        end)
    else
        self:intro()
    end

    if params.died then
        self.player.x = math.random(2) == 1 and VIRTUAL_WIDTH + 10 or -10 - self.player.width
        Timer.tween(1, {
            [self.player] = {x = VIRTUAL_WIDTH / 2 - self.player.width / 2}
        })
    end
end

function AdvanceState:intro()
    self:generateCovers()
    self.coversShown = 40
    Timer.every(0.05, function()
        self.coversShown = self.coversShown - 1
    end)
    Timer.tween(1, {
        [self] = {levelY = VIRTUAL_HEIGHT / 2 - 10}
    }):finish(function()
        Timer.after(1, function()
            Timer.tween(1, {
                [self] = {levelY = VIRTUAL_HEIGHT + 10}
            }):finish(function()
                Timer.after(self.waitTime, function()
                    Timer:clear()
                    if self.fleet.bossLevel then
                        self.fleet.boss.mode = 'h'
                    end
                    gStateMachine:change('play', {
                    highScores = self.highScores,
                    level = self.level,
                    player = self.player,
                    fleet = self.fleet,
                    score = self.score,
                    covers = self.covers
                    })
                end)
            end)
        end)
    end)

    if self.fleet.bossLevel then   
        Timer.tween(6, {
            [self.fleet.boss] = {y = 50}
        })
    else
        gSounds['level_start']:play()
        Timer.tween(2, {
            [self] = {rightLine = 10}
        }):finish(function()
            Timer.tween(1, {
                [self] = {leftLine = 10}
            }):finish(function()
                self.leftLine = 10
            end)
            self.rightLine = 10
        end)
    end
end

function AdvanceState:generateCovers()
    self.covers = {}
    local coverLocations = {
        [1] = 30,
        [2] = VIRTUAL_WIDTH / 2 - 25,
        [3] = VIRTUAL_WIDTH - 80
    }
    for k = 1, 3 do
        self.covers[k] = Cover(coverLocations[k], VIRTUAL_HEIGHT - 45, 10, 4)
    end
end

function AdvanceState:update(dt)
    Timer.update(dt)
    self.fleet:update(dt)
    self.player:update(dt)

    --exit game on escape
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function AdvanceState:render()
    love.graphics.setColor(1, 1, 1, self.alpha)
    self.player:render()
    if self.fleet.bossLevel then
        self.fleet:render()
    else
        for i, column in pairs(self.fleet.fleet) do
            for j, invader in pairs(column) do
                if j % 2 == 0 then
                    invader:intro(self.leftLine + (i - 1) * (invader.width + 10), invader.y)
                else
                    invader:intro(self.rightLine + (i - 1) * (invader.width + 10), invader.y)
                end
            end
        end
    end
    
    for i, cover in pairs(self.covers) do
        cover:render(self.coversShown)
    end
    for i, cover in pairs(self.oldCover) do
        cover:render()
    end
    love.graphics.rectangle('fill', 0, VIRTUAL_HEIGHT - 50, VIRTUAL_WIDTH, 1)

    love.graphics.setColor(255, 0, 0, self.alpha)
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf('LVL ' .. tostring(self.level), 5, 5, VIRTUAL_WIDTH, 'left')
    love.graphics.printf('SCORE ' .. tostring(self.score), 50, 5, VIRTUAL_WIDTH, 'left')

    
    love.graphics.setFont(gFonts['large'])
    love.graphics.setColor(255, 255, 255, self.alpha)
    love.graphics.rectangle('fill', 0, self.levelY - 7, VIRTUAL_WIDTH, 42)
    love.graphics.setColor(0, 0, 0, self.alpha)
    love.graphics.printf('LEVEL ' .. tostring(self.level), 0, self.levelY, VIRTUAL_WIDTH,  'center')
    love.graphics.setColor(255, 255, 255, self.alpha)
end

function AdvanceState:exit() end
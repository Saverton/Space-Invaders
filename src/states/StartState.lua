StartState = Class{__includes = BaseState}

function StartState:enter(params)
    self.highScores = params.highScores

    self.highlightedOption = 0

    self.isOptionSelected = false

    self.alpha = 1

    self.options = {
        [1] = Button(VIRTUAL_WIDTH / 2 - 55, VIRTUAL_HEIGHT / 2, 110, 20, 'PLAY'),
        [2] = Button(VIRTUAL_WIDTH / 2 - 55, VIRTUAL_HEIGHT / 2 + 25, 110, 20, 'HIGH SCORES'),
        [3] = Button(VIRTUAL_WIDTH / 2 - 55, VIRTUAL_HEIGHT / 2 + 50, 110, 20, 'CONTROLS')
    }
    self.showControls = false
    self.exitButton = Button(VIRTUAL_WIDTH / 2 - 20, VIRTUAL_HEIGHT - 30, 40, 20, 'EXIT')
    self.background = love.graphics.newParticleSystem(gTextures['invaders'], 20)
    self.background:setQuads(gFrames['invaders'][math.random(4)])
    self.background:setEmissionArea('uniform', 0, VIRTUAL_HEIGHT / 2 - 10)
    self.background:setEmissionRate(1)
    self.background:setPosition(-20, VIRTUAL_HEIGHT / 2 - 8)
    self.background:setSpeed(30, 100)
    self.background:setParticleLifetime(20, 20)
    self.background:setDirection(0)
    self.particleColor = {1, 1, 1, 1}
    Timer.every(5, function()
        Timer.tween(1, {
            [self.particleColor] = {[4] = 0}
        }):finish(function()
            self.background:setQuads(gFrames['invaders'][math.random(4)])
            Timer.tween(1, {
                [self.particleColor] = {[4] = 1}
            })
        end)
    end)
end

function StartState:update(dt)
    if MouseInput.b == 1 and not self.isOptionSelected then
        if self.highlightedOption == 1 then
            self.isOptionSelected = true
            Timer.tween(1, {
                [self] = {alpha = 0},
                [self.particleColor] = {[1] = 0.05, [2] = 0.1, [3] = 0.1}
            }):finish(function()
                gStateMachine:change('advance', {
                highScores = self.highScores,
                fade_in = true
            })
            end)
        elseif self.highlightedOption == 2 then
            self.isOptionSelected = true
            gStateMachine:change('high-score', {
                highScores = self.highScores
            })
        elseif self.highlightedOption == 3 then
            self.showControls = not self.showControls
            if self.showControls then
                self.options[3]:setText('BACK')
            else
                self.options[3]:setText('CONTROLS')
            end
        end
        if self.highlightedOption ~= 0 then
            gSounds['pause']:play()
        end
    end
    if love.keyboard.wasPressed('escape') or self.exitButton:isPressed() then
        if self.showControls then
            self.showControls = false
            gSounds['pause']:play()
        else
            love.event.quit()
        end
    end
    self.highlightedOption = 0
    for i, button in pairs(self.options) do
        if button:containsMouse() then
            self.highlightedOption = i
        end
    end
    self.background:update(dt)
    Timer.update(dt)
end

function StartState:render()
    love.graphics.setColor(self.particleColor)
    love.graphics.draw(self.background, 0, 0)
    love.graphics.setColor(255, 255, 255, self.alpha)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Space Invaders', 0, VIRTUAL_HEIGHT / 2 - 60, VIRTUAL_WIDTH,  'center')

    love.graphics.setFont(gFonts['medium'])

    if self.showControls then
        love.graphics.setColor(0, 0, 0, self.alpha)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 75, VIRTUAL_HEIGHT / 2 - 30, 150, 60)
        love.graphics.setColor(255, 255, 255, self.alpha)
        love.graphics.rectangle('line', VIRTUAL_WIDTH / 2 - 75, VIRTUAL_HEIGHT / 2 - 30, 150, 60)

        love.graphics.printf('CONTROLS', 0, VIRTUAL_HEIGHT / 2 - 25, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(gFonts['small'])
        love.graphics.printf('Move: left & right arrows', VIRTUAL_WIDTH / 2 - 60, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH + 40, 'left')
        love.graphics.printf('Shoot: space bar', VIRTUAL_WIDTH / 2 - 60, VIRTUAL_HEIGHT / 2 + 10, VIRTUAL_WIDTH + 40, 'left')
        love.graphics.printf('Pause: \'p\' key', VIRTUAL_WIDTH / 2 - 60, VIRTUAL_HEIGHT / 2 + 20, VIRTUAL_WIDTH + 40, 'left')

        love.graphics.setFont(gFonts['medium'])
        if self.highlightedOption == 3 then
            love.graphics.setColor(255, 0, 0, self.alpha)
        end
        self.options[3]:render()
        love.graphics.setColor(255, 255, 255, self.alpha)
    else
        --menu selects
        for i, option in pairs(self.options) do
            option:render(self.alpha)
        end
        self.exitButton:render(self.alpha)
    end

    love.graphics.setFont(gFonts['small'])
    love.graphics.printf('Project by Scott Meadows', 2, VIRTUAL_HEIGHT - 10, VIRTUAL_WIDTH, 'left')
    love.graphics.printf('v1.1', 0, VIRTUAL_HEIGHT - 10, VIRTUAL_WIDTH - 2, 'right')
end

function StartState:exit() end


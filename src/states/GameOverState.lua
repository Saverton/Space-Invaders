GameOverState = Class{__includes = BaseState}

function GameOverState:enter(params)
    self.highScores = params.highScores
    self.score = params.score
    self.fleet = params.fleet
    self.level = params.level
    self.fleet.bullets = {}

    self.newHighScore = self.score > self.highScores[10].score
    self.continueButton = Button(VIRTUAL_WIDTH / 2 - 40, VIRTUAL_HEIGHT - 75, 80, 20, 'CONTINUE')
    self.exitButton = Button(VIRTUAL_WIDTH / 2 - 20, VIRTUAL_HEIGHT - 40, 40, 20, 'EXIT')
end

function GameOverState:update(dt)
    if love.keyboard.wasPressed('Enter') or love.keyboard.wasPressed('return') or self.continueButton:isPressed() then
        if self:highScoreCheck() then
            gStateMachine:change('enter-high-score', {
                highScores = self.highScores,
                score = self.score,
                scoreIndex = self:getHighScoreIndex(),
                level = self.level
            })
        else
            gStateMachine:change('start', {
                highScores = self.highScores
            })
        end
    end

    --exit game on escape
    if love.keyboard.wasPressed('escape') or self.exitButton:isPressed() then
        love.event.quit()
    end
end

function GameOverState:render()
    self.fleet:render()
    love.graphics.rectangle('fill', 0, VIRTUAL_HEIGHT - 50, VIRTUAL_WIDTH, 1)
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 90, VIRTUAL_HEIGHT / 2 - 40, 180, 80)
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.rectangle('line', VIRTUAL_WIDTH / 2 - 90, VIRTUAL_HEIGHT / 2 - 40, 180, 80)

    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('GAME OVER', 0, VIRTUAL_HEIGHT / 2 - 35, VIRTUAL_WIDTH,  'center')

    love.graphics.setFont(gFonts['medium'])
    if self.newHighScore then
        love.graphics.printf('New High Score!', 0, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH,  'center')
    end
    love.graphics.printf('Enter to continue', 0, VIRTUAL_HEIGHT / 2 + 5, VIRTUAL_WIDTH,  'center')

    love.graphics.printf('SCORE ' .. tostring(self.score), 0, VIRTUAL_HEIGHT / 2 + 20, VIRTUAL_WIDTH, 'center')
    self.continueButton:render()
    self.exitButton:render()
end

function GameOverState:exit() end

function GameOverState:highScoreCheck()
    --find min hs value
    local min = self.highScores[1].score
    for i in pairs(self.highScores) do
        if self.highScores[i].score < min then
            min = self.highScores[i].score
        end
    end
    --if score is greater return true
    if self.score > min then
        return true
    else
        return false
    end
end

function GameOverState:getHighScoreIndex()
    local index = 10
    for k = 10, 1, -1 do
        local score = self.highScores[k].score or 0
        if self.score > score then
            index = k
        end
    end
    return index
end
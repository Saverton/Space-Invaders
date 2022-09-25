HighScoreState = Class{__includes = BaseState}

function HighScoreState:enter(params)
    self.highScores = params.highScores
    self.exitButton = Button(VIRTUAL_WIDTH / 2 - 15, VIRTUAL_HEIGHT - 15, 30, 10, 'BACK')
    self.resetButton = Button(VIRTUAL_WIDTH / 2 - 20, VIRTUAL_HEIGHT - 30, 40, 10, 'RESET')
    self.resetPrompt = false
    self.response = {
        ['yes'] = Button(VIRTUAL_WIDTH / 2 - 25, VIRTUAL_HEIGHT / 2, 50, 20, 'YES'),
        ['no'] = Button(VIRTUAL_WIDTH / 2 - 25, VIRTUAL_HEIGHT / 2 + 25, 50, 20, 'NO')
    }
end

function HighScoreState:update(dt)
    if not self.resetPrompt then
        if love.keyboard.wasPressed('escape') or self.exitButton:isPressed() then
            gStateMachine:change('start', {
                highScores = self.highScores
            })
            gSounds['pause']:play()
        end
        if self.resetButton:isPressed() then
            self.resetPrompt = true
        end
    else
        if self.response['yes']:isPressed() then
            self.highScores = ResetHighScores()
            self.resetPrompt = false
        elseif self.response['no']:isPressed() then
            self.resetPrompt = false
        end
    end
end

function HighScoreState:render()
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('HIGH SCORES', 0, 15, VIRTUAL_WIDTH,  'center')

    love.graphics.setFont(gFonts['medium'])
    if not self.resetPrompt then
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.printf('name', 100, 50, VIRTUAL_WIDTH,  'left')
        love.graphics.printf('level', 100, 50, VIRTUAL_WIDTH - 200,  'center')
        love.graphics.printf('score', 100, 50, VIRTUAL_WIDTH / 2, 'right')
        love.graphics.setColor(255, 255, 255, 255)
        for i, score in pairs(self.highScores) do
            love.graphics.printf(score.name, 100, 50 + 14 * i, VIRTUAL_WIDTH,  'left')
            love.graphics.printf(tostring(score.level), 100, 50 + 14 * i, VIRTUAL_WIDTH - 200,  'center')
            love.graphics.printf(tostring(score.score), 100, 50 + 14 * i, VIRTUAL_WIDTH / 2, 'right')
        end

        love.graphics.setFont(gFonts['small'])
        self.exitButton:render()
        self.resetButton:render()
    else
        love.graphics.printf('Are you sure you want\nto reset scores?', 0, 50, VIRTUAL_WIDTH,  'center')
        for i in pairs(self.response) do
            self.response[i]:render()
        end
    end
end

function ResetHighScores()
    local scores = ''
    for i = 1, 10 do
        scores = scores .. '---\n'
        scores = scores .. tostring(0) .. '\n'
        scores = scores .. tostring(0) .. '\n'
    end

    love.filesystem.write('invaders-new.lst', scores)
    
    local name = 0
    local counter = 1
    local scores = {}
    for i = 1, 10 do
        scores[i] = {name = nil, score = nil, level = nil}
    end

    --place high Scores into highScores table
    for line in love.filesystem.lines('invaders-new.lst') do
        if name % 3 == 0 then
            scores[counter].name = string.sub(line, 1, 3)
        elseif name % 3 == 1 then
            scores[counter].score = tonumber(line)
        else
            scores[counter].level = tonumber(line)
            counter = counter + 1
        end

        name = name + 1
    end

    return scores
end

function HighScoreState:exit() end
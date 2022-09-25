EnterHighScoreState = Class{__includes = BaseState}

function EnterHighScoreState:enter(params)
    self.highScores = params.highScores
    self.score = params.score
    self.scoreIndex = params.scoreIndex
    self.level = params.level

    self.name = ''
    self.letters = {
        [1] = '-',
        [2] = '-',
        [3] = '-'
    }
    self.highlightedLetter = 1

    self.continueButton = Button(VIRTUAL_WIDTH / 2 - 100, VIRTUAL_HEIGHT / 2 + 30, 200, 20, 'Enter High Score')
end

function EnterHighScoreState:update(dt)
    if love.keyboard.wasPressed('left') then
        self.highlightedLetter = math.max(1, self.highlightedLetter - 1)
        gSounds['invader_moves'][1]:play()
    elseif love.keyboard.wasPressed('right') then
        self.highlightedLetter = math.min(3, self.highlightedLetter + 1)
        gSounds['invader_moves'][2]:play()
    end

    if string.len(GetCharInput()) > 0 then
        gSounds['invader_moves'][2]:play()
        self.letters[self.highlightedLetter] = GetCharInput()
        self.highlightedLetter = math.min(self.highlightedLetter + 1, 3)
    end

    if love.keyboard.wasPressed('backspace') then
        gSounds['invader_moves'][1]:play()
        self.letters[self.highlightedLetter] = '-'
        self.highlightedLetter = math.max(1, self.highlightedLetter - 1)
    end

    if (love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') or self.continueButton:isPressed()) then
        if not EnterHighScoreState.stringContains('' .. self.letters[1] .. self.letters[2] .. self.letters[3], '-') then
            local nameEntered = ''
            for i = 1, 3 do
                nameEntered = nameEntered .. self.letters[i]
            end
            
            --shift scores
            for k = 10, self.scoreIndex + 1, -1 do
                self.highScores[k] = {
                    name = self.highScores[k - 1].name,
                    score = self.highScores[k - 1].score,
                    level = self.highScores[k - 1].level
                }
            end

            self.highScores[self.scoreIndex].name = nameEntered
            self.highScores[self.scoreIndex].score = self.score
            self.highScores[self.scoreIndex].level = self.level

            local scoresStr = ''
            for i = 1, 10 do
                scoresStr = scoresStr .. self.highScores[i].name .. '\n'
                scoresStr = scoresStr .. tostring(self.highScores[i].score) .. '\n'
                scoresStr = scoresStr .. tostring(self.highScores[i].level) .. '\n'
            end

            love.filesystem.write('invaders-new.lst', scoresStr)

            gStateMachine:change('high-score', {
                highScores = self.highScores
            })
        else
            gSounds['cover_destroyed']:play()
        end
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function EnterHighScoreState:render()
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('NEW HIGH SCORE!', 0, 40, VIRTUAL_WIDTH,  'center')
    
    for i = 1, 3 do
        if self.highlightedLetter == i then
            love.graphics.setColor(255, 0, 0, 255)
        end
        love.graphics.printf(self.letters[i], VIRTUAL_WIDTH / 2 - 50 + 20 * i, VIRTUAL_HEIGHT / 2 - 5, VIRTUAL_WIDTH, "left")

        love.graphics.setColor(255, 255, 255, 255)
    end
    
    love.graphics.printf('SCORE: ' .. tostring(self.score), 0, VIRTUAL_HEIGHT - 60, VIRTUAL_WIDTH,  'center')
    love.graphics.printf('LEVEL: ' .. tostring(self.level), 0, VIRTUAL_HEIGHT - 30, VIRTUAL_WIDTH,  'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Enter Initials, then press \'Enter\'', 0, 70, VIRTUAL_WIDTH,  'center')
    self.continueButton:render()
end

function EnterHighScoreState:exit() end

function EnterHighScoreState.stringContains(s, c)
    for i = 1, string.len(s), 1 do
        if string.sub(s, i, i + 1) == c then
            return true
        end
    end
    return false
end
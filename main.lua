--[[
    An improved build of Space Invaders, incorporating more organized and modular design using state machines, more tables,
    also adding multiple levels, a high score system, and a "boss" fought every 12 levels.

    @author Saverton
]]

require ('src/Dependencies')

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    love.window.setTitle('Space Invaders')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    gSounds = {
        ['invader_moves'] = {
            [1] = love.audio.newSource('sounds/invader_move1.wav', 'static'),
            [2] = love.audio.newSource('sounds/invader_move2.wav', 'static')
        },
        ['invader_descends'] = love.audio.newSource('sounds/invader_descends.wav', 'static'),
        ['invader_dies'] = love.audio.newSource('sounds/invader_dies.wav', 'static'),
        ['defeated'] = love.audio.newSource('sounds/defeated.wav', 'static'),
        ['shoot'] = love.audio.newSource('sounds/shoot.wav', 'static'),
        ['efire_hits'] = love.audio.newSource('sounds/efire_hits.wav', 'static'),
        ['invader_shoot'] = love.audio.newSource('sounds/invader_shoot.wav', 'static'),
        ['cover_destroyed'] = love.audio.newSource('sounds/cover_destroyed.wav', 'static'),
        ['level_start'] = love.audio.newSource('sounds/level-start.wav', 'static'),
        ['empty_ammo'] = love.audio.newSource('sounds/empty_ammo.wav', 'static'),
        ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),
        ['reverse'] = love.audio.newSource('sounds/reverse.wav', 'static'),

        ['final-boss'] = love.audio.newSource('sounds/final-boss.wav', 'static'),
        ['final-boss-loop'] = love.audio.newSource('sounds/final-boss-main.wav', 'static')
    }
    AudioLevel = 0.5
    love.audio.setVolume(AudioLevel)

    gSoundButtons = {
        ['-'] = Button(VIRTUAL_WIDTH / 2 + 35, 5, 6, 6),
        ['+'] = Button(VIRTUAL_WIDTH / 2 + 41, 5, 6, 6)
    }

    gTextures = {
        ['tank'] = love.graphics.newImage('graphics/Tank.png'),
        ['invaders'] = love.graphics.newImage('graphics/invaders.png'),
        ['life'] = love.graphics.newImage('graphics/life.png'),
        ['final'] = love.graphics.newImage('graphics/Final_Invader.png'),
        ['particle'] = love.graphics.newImage('graphics/particle.png'),
        parachute = love.graphics.newImage('graphics/parachute.png')
    }

    gFrames = {
        ['invaders'] = generateQuads(gTextures['invaders'], 16, 16, 0, 4),
        ['final_invader'] = generateQuads(gTextures['final'], 32, 16, 0, 1),
        ['defender'] = generateQuads(gTextures['final'], 16, 16, 2, 1),
    }

    gFonts = {
        ['large'] = love.graphics.newFont('font.ttf', 32),
        ['medium'] = love.graphics.newFont('font.ttf', 16),
        ['small'] = love.graphics.newFont('font.ttf', 8)
    }
    love.graphics.setFont(gFonts['large'])

    gStateMachine = StateMachine({
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['advance'] = function() return AdvanceState() end,
        ['game-over'] = function() return GameOverState() end,
        ['enter-high-score'] = function() return EnterHighScoreState() end,
        ['high-score'] = function() return HighScoreState() end
    })
    gStateMachine:change('start', {
        highScores = loadHighScores()
    })

    love.keyboard.keysPressed = {}
    MouseInput = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
    MouseInput = {}
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function GetCharInput()
    for i = 0, 25, 1 do
        if love.keyboard.wasPressed(string.char(i + 97)) then
            return string.char(i + 65)
        end
    end
    return ''
end

function love.mousepressed(x, y, button)
    MouseInput = {
        mx, my = push:toGame(x, y),
        b = button or 0
    }
    if button == 1 then
        if gSoundButtons['-']:isPressed() then
            AudioLevel = math.max(0, AudioLevel - 0.1)
            love.audio.setVolume(AudioLevel)
            gSounds['invader_moves'][2]:play()
        elseif gSoundButtons['+']:isPressed() then
            AudioLevel = math.min(1, AudioLevel + 0.1)
            love.audio.setVolume(AudioLevel)
            gSounds['invader_moves'][2]:play()
        end
    end
end

function CursorCollides(x, y, w, h)
    local mx, my = push:toGame(love.mouse.getPosition())
    if mx == nil or my == nil then
        return false
    end
    if mx < x or mx > x + w then
        return false
    end

    if my < y or my > y + h then
        return false
    end
    return true
end

function love.draw()
    push:apply('start')
    love.graphics.setColor(0.05, 0.1, 0.1, 1)
    love.graphics.rectangle('fill' , 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.print('AUDIO', VIRTUAL_WIDTH / 2 - 50, 5)
    for i = 0, 10 * AudioLevel + 0.01 do
        love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 20 + 5 * i, 5, 4, 5)
    end
    love.graphics.print('- +', VIRTUAL_WIDTH / 2 + 35, 5)
    love.graphics.setColor(255, 255, 255, 255)

    gStateMachine:render()

    push:apply('end')
end

function loadHighScores()
    love.filesystem.setIdentity('invaders-new')

    if not love.filesystem.getInfo('invaders-new.lst') then
        local scores = ''
        for i = 1, 10 do
            scores = scores .. '---\n'
            scores = scores .. tostring(0) .. '\n'
            scores = scores .. tostring(0) .. '\n'
        end

        love.filesystem.write('invaders-new.lst', scores)
    end

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
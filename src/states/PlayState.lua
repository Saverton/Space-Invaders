--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level

    self.recoverPoints = params.recoverPoints or 5000
    self.growPoints = params.growPoints or 3000
    self.powerups = {}
    self.nextKeyDrop = false

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    for k, ball in pairs(self.balls) do
        ball:update(dt)

        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy
    
            --
            -- tweak angle of bounce based on where it hits the paddle
            --
    
            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end
    
            gSounds['paddle-hit']:play()
        end
    end

    -- detect collision across all bricks with the ball
    local unlockedRemaining = 0
    for k, brick in pairs(self.bricks) do
        -- only check collision if we're in play
        if not (brick.locked == 2) then
            unlockedRemaining = unlockedRemaining + 1
        end
        for k, ball in pairs(self.balls) do
            if brick.inPlay and ball:collides(brick) then

                -- add to score
                if not (brick.locked == 2) then
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)
                end

                -- trigger the brick's hit function, which removes it from play
                brick:hit(self.paddle.key)
    
                -- if we have enough points, recover a point of health
                if self.score > self.growPoints then
                    self.paddle:grow()
                    self.growPoints = self.growPoints + math.min(50000, self.growPoints * 2)
                end

                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)
    
                    -- multiply recover points by 2
                    self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)
    
                    -- play recover sound effect
                    gSounds['recover']:play()
                end
    
                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()
    
                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        balls = self.balls,
                        recoverPoints = self.recoverPoints,
                        growPoints = self.growPoints
                    })
                end
    
                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --
    
                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end
    
                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end
    
                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    if (unlockedRemaining == 0) and not (self.paddle.key) and (#self.powerups == 0) then
        gStateMachine:change('game-over', {
            score = self.score,
            highScores = self.highScores
        })
    elseif (unlockedRemaining == 1) and not (self.paddle.key) then
        self.nextKeyDrop = true
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    for k, ball in pairs(self.balls) do
        if ball.y >= VIRTUAL_HEIGHT then
            if #self.balls == 1 then
                self.health = self.health - 1
                gSounds['hurt']:play()
                self.paddle:shrink()
                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        recoverPoints = self.recoverPoints,
                        growPoints = self.growPoints
                    })
                end
            else
                table.remove(self.balls, k)
            end
        end
    end
    
    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    --updates powerups and checks collision across powerup and player
    for k, powerup in pairs(self.powerups) do
        if powerup.active then
            powerup:update(dt)
            if self.paddle.x < powerup.x + powerup.width and self.paddle.x + self.paddle.width > powerup.x then
                if self.paddle.y < powerup.y + powerup.height and self.paddle.y + self.paddle.height > powerup.y then
                    powerup.active = false
                    gSounds['powerup-get']:play()
                    if powerup.type == 1 then
                        for i = 1, 2 do
                            if #self.balls < 3 then
                                table.insert(self.balls, Ball(math.random(7), math.random(-200, 200), math.random(-50, -60)))
                            end
                        end
                    elseif powerup.type == 2 then
                        self.paddle.key = true
                    end
                end
            end
            if powerup.y > VIRTUAL_HEIGHT then
                powerup.active = false
            end
        else
            --if powerup is inactive then despawn it
            table.remove(self.powerups, k)
        end
    end
    
    if love.keyboard.wasPressed('r') then
        for b, ball in pairs(self.balls) do
            ball:resetPos()
        end

    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    --render powerups
    for k, powerup in pairs(self.powerups) do
        if powerup.active then
            powerup:render()
        end
    end

    self.paddle:render()
    for k, ball in pairs(self.balls) do
        ball:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end
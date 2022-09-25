Tank = Class{}

function Tank:init()
    self.image = gTextures['tank']
    self.width = self.image:getWidth()
    self.height = self.image:getHeight() - 4

    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT - 5 - self.height
    self.dx = 0

    self.bullets = {}

    self.lives = 3
end

function Tank:update(dt)
    if love.keyboard.isDown('left') then
        self.dx = -100
    elseif love.keyboard.isDown('right') then
        self.dx = 100
    else
        self.dx = 0
    end

    if self.dx > 0 then
        self.x = math.min(self.x + self.dx * dt, VIRTUAL_WIDTH - self.width)
    elseif self.dx < 0 then
        self.x = math.max(self.x + self.dx * dt, 0)
    end

    if love.keyboard.wasPressed('space') and gStateMachine.currentName == 'play' then
        self:shoot()
    end

    --update bullet pos
    for k, bullet in pairs(self.bullets) do
        bullet:update(dt)
    end
    --remove bullets past top of screen
    for k, bullet in pairs(self.bullets) do
        if bullet.y < 0 then
            table.remove(self.bullets, k)
        end
    end
end

function Tank:shoot()
    if #self.bullets < 3 then
        --fire projectile
        gSounds['shoot']:stop()
        gSounds['shoot']:play()
        table.insert(self.bullets, Bullet(self.x + self.width / 2, self.y - 4, -100))
    else
        --play empty ammo sound
        gSounds['empty_ammo']:stop()
        gSounds['empty_ammo']:play()
    end
end

function Tank:reset()
    self.lives = self.lives - 1
    self.bullets = {}
    self.dx = 0
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
end

function Tank:render()
    love.graphics.draw(self.image, self.x, self.y)
    for k, bullet in pairs(self.bullets) do
        bullet:render()
    end
    for i = 1, self.lives do
        love.graphics.draw(gTextures['life'], VIRTUAL_WIDTH - 42 + 10 * i, 2)
    end
end
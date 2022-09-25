Button = Class{}

function Button:init(x, y, w, h, text)
    self.x = x
    self.y = y
    self.width = w
    self.height = h

    self.text = text or ''
end

function Button:isPressed()
    if self:containsMouse() and MouseInput.b == 1 then
        return true
    end
    return false
end

function Button:containsMouse()
    if CursorCollides(self.x, self.y, self.width, self.height) then
        return true
    else
        return false
    end
end

function Button:render(alpha)
    local a = alpha or 1
    if self:containsMouse() then
        love.graphics.setColor(255, 0, 0, a)
    else
        love.graphics.setColor(255, 255, 255, a)
    end
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    love.graphics.printf(self.text, 0, self.y + math.max(self.height - 16, 2), VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, a)
end

function Button:setText(text)
    self.text = text
end
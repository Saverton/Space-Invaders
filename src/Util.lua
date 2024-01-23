function generateQuads(atlas, tileWidth, tileHeight, startTile, counterMax)
    local sheetWidth = atlas:getWidth() / tileWidth
    local sheetHeight = atlas:getHeight() / tileHeight

    local counter = 1
    local quads = {}
    for i = 0, sheetHeight - 1 do
        for j = startTile, sheetWidth - 1 do
            quads[counter] = love.graphics.newQuad(j * tileWidth, i * tileHeight, tileWidth,
                tileHeight, atlas:getDimensions())
            counter = counter + 1
            if counter > counterMax then
                goto finish
            end
        end
    end

    ::finish::
    return quads
end

function DidCollide(entityA, entityB)
    assert(
    entityA.x and entityA.y and entityB.x and entityB.y and entityA.width and entityA.height and entityB.width and
    entityB.height, 'Both entities must have non-nil x, y, width, and height properties')
    
    return not (entityA.x + entityA.width < entityB.x)
        and not (entityA.x > entityB.x + entityB.width)
        and not (entityA.y + entityA.height < entityB.y)
        and not (entityA.y > entityB.y + entityB.height)
end
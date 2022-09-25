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
local module = {}

-- module.font = love.graphics.newFont("gui/pixelated.ttf", 8)
module.font = love.graphics.newImageFont("gui/font.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%`'*#=[]")
module.font:setFilter("nearest", "nearest")

function module.bar(sx, sy, ex, ey, bgc, fgc, v)
    love.graphics.setColor(bgc[1], bgc[2], bgc[3], bgc[4] or 1)
    love.graphics.rectangle("fill", sx, sy, ex, ey)

    love.graphics.setColor(fgc[1], fgc[2], fgc[3], fgc[4] or 1)

    local vx = ((ex - sx) * v) + (sx - 2)

    love.graphics.rectangle("fill", sx + 1, sy + 1, vx, ey - 2)
end

function module.outlined_text(what, x, y, limit, align, outlinec, textc, size)
    size = size or 3

    love.graphics.setColor(outlinec[1], outlinec[2], outlinec[3], outlinec[4] or 1)

    for i = 0, size do
        love.graphics.printf(what, x - (size - i), y, limit, align)
        love.graphics.printf(what, x + (size - i), y, limit, align)
        love.graphics.printf(what, x, y - (size - i), limit, align)
        love.graphics.printf(what, x, y + (size - i), limit, align)

        love.graphics.printf(what, x - (size - i), y - (size - i), limit, align)
        love.graphics.printf(what, x + (size - i), y + (size - i), limit, align)
        love.graphics.printf(what, x - (size - i), y + (size - i), limit, align)
        love.graphics.printf(what, x + (size - i), y - (size - i), limit, align)
    end

    love.graphics.setColor(textc[1], textc[2], textc[3], textc[4] or 1)
    love.graphics.printf(what, x, y, limit, align)
end

return module
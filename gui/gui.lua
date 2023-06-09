local module = {}

module.font = love.graphics.newFont("gui/pixelated.ttf", 8)
module.font:setFilter("nearest", "nearest")

function module.bar(sx, sy, ex, ey, bgc, fgc, v)
    love.graphics.setColor(bgc[1], bgc[2], bgc[3], bgc[4] or 1)
    love.graphics.rectangle("fill", sx, sy, ex, ey)

    love.graphics.setColor(fgc[1], fgc[2], fgc[3], fgc[4] or 1)

    local vx = ((ex - sx) * v) + sx

    love.graphics.rectangle("fill", sx, sy, vx, ey)
end

return module
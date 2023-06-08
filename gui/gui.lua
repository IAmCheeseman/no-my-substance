local module = {}

module.font = love.graphics.newFont("gui/pixelated.ttf", 8)
module.font:setFilter("nearest", "nearest")

return module
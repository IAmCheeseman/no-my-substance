Game = require "core"

love.graphics.setDefaultFilter("nearest", "nearest")
require "definetypes"

current_level = 1

function get_current_level()
    return "Level_" .. current_level
end

function love.load()
    Room.initialize("", "levels.ldtk", get_current_level())
end

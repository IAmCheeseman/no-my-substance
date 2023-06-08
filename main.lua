Game = require "core"

love.graphics.setDefaultFilter("nearest", "nearest")
require "definetypes"

current_level = 0

function love.load()
    Room.initialize("", "levels.ldtk", "Level_" .. tostring(current_level))

    Objects.instance("Pauser")
    Objects.instance("Camera")
    Objects.instance("CommandExecutor")
end

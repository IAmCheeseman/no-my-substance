Game = require "core"

love.graphics.setDefaultFilter("nearest", "nearest")
require "definetypes"

current_level = 1

function love.load()
    Objects.instance("Logger")
    Objects.instance("Pauser")
    Objects.instance("Camera")
    Objects.instance("CommandExecutor")
    
    Room.initialize("", "levels.ldtk", "Level_" .. tostring(current_level))
end

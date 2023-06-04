Game = require "base.lib"


love.graphics.setDefaultFilter("nearest", "nearest")
require "definetypes"

current_level = 0

function love.load()
    Room.initialize("", "levels.ldtk", "Level_" .. tostring(current_level))

    Objects.create_object("Pauser")
    Objects.create_object("Camera")
end

Game = require "core"

local data_collection = require "datacollection"
local save_data = require "savedata"

love.graphics.setDefaultFilter("nearest", "nearest")
require "definetypes"

current_level = 1

function get_current_level()
    return "Level_" .. current_level
end

function love.load()
    save_data.load()
    Room.initialize("", "levels.ldtk", get_current_level())
    data_collection:initialize()
    data_collection:entered_level()
end

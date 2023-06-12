Game = require "core"

love.graphics.setDefaultFilter("nearest", "nearest")
require "definetypes"

current_level = 1

local music = love.audio.newSource("nmstheme.mp3", "static")
music:setLooping(true)

function get_current_level()
    return "Level_" .. current_level
end

function love.load()
    Objects.instance("Logger")
    Objects.instance("Pauser")
    Objects.instance("Camera")
    Objects.instance("CommandExecutor")
    Objects.instance("VoiceLinePlayer")
    Objects.instance("BloodManager")

    Room.initialize("", "levels.ldtk", get_current_level())

    music:play()
end

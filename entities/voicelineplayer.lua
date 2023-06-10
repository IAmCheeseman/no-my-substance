local gui = require "gui.gui"

local module = {}

local current = {}

function module.play_line(from, audio, priority, speaker, subtitle)
    if current[from.type] ~= nil then
        return false
    end

    local subtitled = speaker ~= nil and subtitle ~= nil

    if subtitled then
        subtitle = string.upper(speaker .. ": " .. subtitle)
    else
        subtitle = ""
    end

    current[from.type] = {
        audio = audio,
        subtitle = subtitle,
        priority = priority,
        subtitled = subtitled,
    }

    audio:play()
    
    return true
end

if not Objects.does_type_exist("VoiceLinePlayer") then
    Objects.create_type("VoiceLinePlayer", {
        persistent = true,

        on_update = function(self, dt)
            for k, v in pairs(current) do
                if not v.audio:isPlaying() then
                    current[k] = nil
                end
            end
        end,

        on_gui = function(self)
            local line = nil
            for _, v in pairs(current) do
                if line == nil or line.priority > v.priority and line.subtitled then
                    line = v
                end
            end

            if line ~= nil then
                love.graphics.setFont(gui.font)
                love.graphics.printf(line.subtitle, 5, 170, 320, "center")
            end
        end
    })
end

return module
local gui = require "gui.gui"

local module = {}

local current = {}

function module.play_line(audio, priority, speaker, subtitle)
    if current[speaker] ~= nil then
        if current[speaker].priority <= priority then
            return false
        end

        current[speaker].audio:stop()
    end

    local subtitled = speaker ~= nil and subtitle ~= nil

    if subtitled then
        subtitle = string.upper(speaker .. ": " .. subtitle)
    else
        subtitle = ""
    end

    current[speaker] = {
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
            local i = 1
            for _, v in pairs(current) do
                local x, y = 0, 170 - ((i - 1) * 8)

                if v.subtitled then
                    love.graphics.setFont(gui.font)
                    local width, height = gui.font:getWidth(v.subtitle) + 5, gui.font:getHeight(v.subtitle)
                    local bgx, bgy = 320 / 2 - width / 2, y

                    love.graphics.setColor(0, 0, 0, 1)
                    love.graphics.rectangle("fill", bgx, bgy, width, height)
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.printf(v.subtitle, x, y, 320, "center")
                end

                i = i + 1
            end
        end
    })
end

return module
local gui = require "gui.gui"

local module = {}
local logger = nil

function module.log_message(message) 
    logger:add_message(message)
end

if not Objects.does_type_exist("Logger") then
    local loggero = {
        persistent = true,
        pause_mode = "never",
        depth = 100000,

        messages = {},
    }

    function loggero:add_message(message)
        table.insert(self.messages, 1, {
            message = string.upper(message),
            time_left = 5,
        })
    end

    function loggero:on_create()
        logger = self
    end

    function loggero:on_room_change(room_name)
        if Room.properties.name then
            self:add_message(Room.properties.name)
        end
    end

    function loggero:on_update(dt)
        for i = #self.messages, 1, -1 do
            local message = self.messages[i]
            message.time_left = message.time_left - dt

            if message.time_left <= 0 then
                table.remove(self.messages, i)
            end
        end
    end

    function loggero:on_gui()
        love.graphics.setFont(gui.font)
        for i, v in ipairs(self.messages) do
            local x, y = 0, (i - 1) * 8

            local width, height = gui.font:getWidth(v.message) + 5, gui.font:getHeight(v.message)
            local bgx, bgy = 320 / 2 - width / 2, y

            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("fill", bgx, bgy, width, height)

            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf(v.message, x, y, 320, "center")
        end
    end

    Objects.create_type("Logger", loggero)

    Objects.instance("Logger")
end

return module
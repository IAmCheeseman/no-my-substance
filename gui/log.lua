local gui = require "gui.gui"

local module = {}
local logger = nil

function module.log_message(message) 
    logger:add_message(message)
end

if not Objects.does_type_exist("Logger") then
    Objects.create_type("Logger", {
        persistent = true,
        pause_mode = "never",
        depth = 100000,

        messages = {},
        
        add_message = function(self, message)
            table.insert(self.messages, 1, {
                message = string.upper(message),
                time_left = 5,
            })
        end,

        on_create = function(self)
            logger = self
        end,

        on_room_change = function(self, room_name)
            if Room.properties.name then
                self:add_message(Room.properties.name)
            end
        end,

        on_update = function(self, dt)
            for i = #self.messages, 1, -1 do
                local message = self.messages[i]
                message.time_left = message.time_left - dt

                if message.time_left <= 0 then
                    table.remove(self.messages, i)
                end
            end
        end,

        on_gui = function(self)
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
    })
end

return module
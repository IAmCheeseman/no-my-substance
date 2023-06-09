local gui = require "gui.gui"

local module = {}
local logger = nil

function module.log_message(message) 
    logger:add_message(message)
end

if not Objects.does_type_exist("Logger") then
    Objects.create_type("Logger", {
        persistent = true,
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
                local alpha = v.time_left / 3
                love.graphics.setColor(1, 1, 1, alpha)
                love.graphics.printf(v.message, 5, (i - 1) * 8, 160, "left")
            end
            love.graphics.setColor(1, 1, 1, 1)
        end
    })
end

return module
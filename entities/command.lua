local logger = require "gui.log"

godmode = false

local function is_key_valid(command, key, commands)
    for k, _ in pairs(commands) do
        if string.gmatch(command, k) then
            return true
        end
    end
    return false
end

local function get_command(command, commands)
    for k, v in pairs(commands) do
        print(command, k)
        if string.find(command, k) ~= nil then
            return v
        end
    end
    return nil
end

Objects.create_type("CommandExecutor", {
    persistent = true,

    current_command = "",

    commands = {
        ["chlvl%d"] = function(self)
            local level = string.gsub(self.current_command, "[^%d]", "")
            current_level = tonumber(level)
            Room.change_to("Level_" .. level)

            logger.log_message("Changed to level #" .. level)
        end,
        ["gmd"] = function(self)
            godmode = not godmode

            logger.log_message("Godmode is " .. (godmode and "on" or "off"))
        end
    },

    on_key_press = function(self, key, _, _)
        local command = get_command(self.current_command, self.commands)
        if key == "return" and command ~= nil then
            command(self)
            self.current_command = ""
            return
        end

        self.current_command = self.current_command .. key

        if not is_key_valid(self.current_command, key, self.commands) then
            self.current_command = ""
            return
        end
    end
})
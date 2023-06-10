local logger = require "gui.log"

godmode = false
player_invisible = false

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
        if string.find(command, k) ~= nil then
            return v
        end
    end
    return nil
end

local function kill_player()
    local player = Objects.grab("Player")
    player:take_damage(player.max_health, 0, 0)

    logger.log_message("Killed player")
end

local function reset_health()
    local player = Objects.grab("Player")
    player.health = player.max_health

    logger.log_message("Reset health")
end

Objects.create_type("CommandExecutor", {
    persistent = true,

    current_command = "",

    commands = {
        ["/clev%d"] = function(self)
            local level = string.gsub(self.current_command, "[^%d]", "")
            current_level = tonumber(level)
            Room.change_to(get_current_level())

            logger.log_message("Changed to level #" .. level)
        end,
        ["/testl"] = function(self)
            Room.change_to("TestRoom")

            logger.log_message("Changed to test room")
        end,
        ["/gmd"] = function(self)
            godmode = not godmode

            logger.log_message("Godmode is " .. (godmode and "on" or "off"))
        end,
        ["/shp%d"] = function(self)
            local health = string.gsub(self.current_command, "[^%d]", "")
            local player = Objects.grab("Player")
            player.health = math.clamp(tonumber(health), 0, player.max_health)

            logger.log_message("Set health to " .. health .. "/" .. player.max_health)
        end,
        ["/dmg%d"] = function(self)
            local damage = string.gsub(self.current_command, "[^%d]", "")
            local player = Objects.grab("Player")
            player:take_damage(damage, 0, 0)

            logger.log_message("Dealt " .. damage .. " damage to player")
        end,
        ["/rhp"] = function(self)
            reset_health()
        end,
        ["/oli"] = function(self)
            reset_health()
        end,
        ["/kill"] = function(self)
            kill_player()
        end,
        ["/kall"] = function(self)
            Objects.with("Enemy", function(other)
                other:take_damage(other.max_health, 0, 0)
            end)

            logger.log_message("Killed all enemies")
        end,
        ["/dot32"] = function(self)
            kill_player()
        end,
        ["/ivis"] = function(self)
            player_invisible = not player_invisible

            logger.log_message("Invisibility is " .. (player_invisible and "on" or "off"))
        end,
    },

    on_key_press = function(self, key, _, _)
        if key == "/" then
            self.current_command = ""
        end

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
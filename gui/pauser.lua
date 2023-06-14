local gui = require "gui.gui"

local pauser = {
    persistent = true,
    depth = 50,

    pause_mode = "never",
    
    ui_elements = {},
}

function pauser:new_ui_element(type, x, y)
    local element = Objects.instance_at(type, x, y)
    element.pause_mode = "never"
    element.depth = 51
    table.insert(self.ui_elements, element)
    return element
end

function pauser:update_pause_menu()
    if Objects.are_paused then
        local title = self:new_ui_element("Label", 50, 60)
        title.text = "PAUSED"

        local continue = self:new_ui_element("Button", 50, 80)
        continue.text = "Continue"
        continue.on_click = function()
            Objects.toggle_pause()
            self:update_pause_menu()
        end    

        local volume = self:new_ui_element("Button", 50, 100)
        volume.text = love.audio.getVolume() == 0 and "Volume: Off" or "Volume: On"
        volume.on_click = function()
            if love.audio.getVolume() == 0 then
                love.audio.setVolume(1)
                volume.text = "VOLUME: ON"
            else
                love.audio.setVolume(0)
                volume.text = "VOLUME: OFF"
            end
        end

        local subtitles = self:new_ui_element("Button", 50, 120)
        local voiceline_player = Objects.grab("VoiceLinePlayer")
        subtitles.text = voiceline_player.subtitles and "Subtitles: On" or "Subtitles: Off"
        subtitles.on_click = function()
            if voiceline_player.subtitles then
                voiceline_player.subtitles = false
                subtitles.text = "SUBTITLES: OFF"
            else
                voiceline_player.subtitles = true
                subtitles.text = "SUBTITLES: ON"
            end
        end

        local exit = self:new_ui_element("Button", 50, 140)
        exit.text = "Exit"
        exit.on_click = love.window.close
    else
        for _, v in ipairs(self.ui_elements) do
            Objects.destroy(v)
        end
        self.ui_elements = {}
    end
end

function pauser:on_gui()
    if not Objects.are_paused then
        return
    end

    local x, y, w, h = 20, 55, 80, 150

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", x, y, w - x, h - y)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", x, y, w - x, h - y)

    gui.outlined_text(string.upper(
        [[
/gmd - godmode
/shp## - set health
/rhp - reset health
/dmg## - deal damage to player
/clev## - change level
/testl - test level
/kill - kill player
/kall - kill all enemies
/ivis - enemies ignore you
/usub - unlock substance
/sub - activate substance
/count... - count object
/inst... - instance object
        ]]), 320 / 2, 32, 320, "left", { 0, 0, 0 }, { 1, 0, 1 }, 1)
end

function pauser:on_key_press(key, _, is_repeat)
    if key == "escape" and not is_repeat then
        Objects.toggle_pause()
        self:update_pause_menu()
    end
end

Objects.create_type("Pauser", pauser)
Objects.instance("Pauser")
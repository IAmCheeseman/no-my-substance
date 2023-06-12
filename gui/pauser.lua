Objects.create_type("Pauser", {
    persistent = true,
    depth = 50,

    pause_mode = "never",
    
    ui_elements = {},

    new_ui_element = function(self, type, x, y)
        local element = Objects.instance_at(type, x, y)
        element.pause_mode = "never"
        element.depth = 51
        table.insert(self.ui_elements, element)
        return element
    end,

    update_pause_menu = function(self)
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

            local exit = self:new_ui_element("Button", 50, 120)
            exit.text = "Exit"
            exit.on_click = love.window.close
        else
            for _, v in ipairs(self.ui_elements) do
                Objects.destroy(v)
            end
            self.ui_elements = {}
        end
    end,    

    on_gui = function(self)
        if not Objects.are_paused then
            return
        end

        local x, y, w, h = 20, 55, 80, 130

        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", x, y, w - x, h - y)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("line", x, y, w - x, h - y)
    end,

    on_key_press = function(self, key, _, is_repeat)
        if key == "escape" and not is_repeat then
            Objects.toggle_pause()
            self:update_pause_menu()
        end
    end
})
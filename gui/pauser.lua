Objects.create_type("Pauser", {
    persistent = true,
    depth = 10000,

    pause_mode = "never",
    
    on_draw = function(self)
        if Objects.are_paused then
            love.graphics.printf("PAUSED", Game.camera_x - 32, Game.camera_y, 64, "center")
        end
    end,
    on_key_press = function(self, key, _, is_repeat)
        if key == "escape" and not is_repeat then
            Objects.are_paused = not Objects.are_paused
        end
    end
})
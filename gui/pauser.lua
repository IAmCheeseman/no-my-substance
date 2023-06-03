Objects.create_type("Pauser", {
    persistent = true,

    pause_mode = "never",
    
    on_key_press = function(self, key, _, is_repeat)
        if key == "escape" and not is_repeat then
            Objects.are_paused = not Objects.are_paused
        end
    end
})
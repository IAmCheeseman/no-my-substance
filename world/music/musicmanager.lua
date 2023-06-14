local music_manager = {
    persistent = true,

    current_path = nil,
    target_path = nil,

    current_track = nil,
    target_track = nil,

    target_volume = 0.3,
    current_volume = 0,
}

function music_manager:on_room_change(room_name)
    local filepath = Room.properties.music
    if filepath ~= nil then
        self.target_track = love.audio.newSource(filepath, "stream")
        self.target_track:setVolume(0)
        self.target_track:setLooping(true)
        self.target_track:play()
    else
        self.target_track = nil
    end
    self.target_path = filepath
end

function music_manager:on_update(dt)
    if self.current_path ~= self.target_path then
        if self.current_path == nil or self.current_volume <= 0.01 then
            if self.current_path ~= nil then
                self.current_track:pause()
            end

            self.current_track = self.target_track
            self.current_path = self.target_path
            self.current_volume = 0
            return
        end

        self.current_volume = math.lerp(self.current_volume, 0, 3 * dt)
    else
        self.current_volume = math.lerp(self.current_volume, self.target_volume, 3 * dt)
    end

    if self.current_track ~= nil then
        self.current_track:setVolume(self.current_volume)
    end
end

Objects.create_type("MusicManager", music_manager)

Objects.instance("MusicManager")
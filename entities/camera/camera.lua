Objects.create_type("Camera", {
    persistent = true,

    wx = 0,
    wy = 0,

    sx = 0,
    sy = 0,

    tracked = nil,

    track_speed = 25,

    on_update = function(self, dt)
        if self.tracked == nil then
            return
        end

        local mx, my = love.mouse.getPosition()
        mx = mx - self.tracked.x
        my = my - self.tracked.y

        self.wx = mx * 0.06
        self.wy = my * 0.06

        Game.camera_x = math.lerp(Game.camera_x, self.tracked.x + self.wx,       self.track_speed * dt)
        Game.camera_y = math.lerp(Game.camera_y, (self.tracked.y - 8) + self.wy, self.track_speed * dt)
    end,
})
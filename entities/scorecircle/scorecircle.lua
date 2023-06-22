local score_circle = {
    radius = 32,
}

function score_circle:reposition()
    self.x, self.y = love.math.random(Room.room_width), love.math.random(Room.room_height)
    if Room.get_cell("Solids", self.x, self.y) ~= 0 then
        self:reposition()
    end
end

function score_circle:on_create()
    self.player = Objects.grab("Player")
    self:reposition()
end

function score_circle:on_update(dt)
    if Vector.distance_between(self.x, self.y, self.player.x, self.player.y) < self.radius then
        local wave_manger = Objects.grab("WaveManager")
        wave_manger:wave_start()
        self:reposition()
    end
end

function score_circle:on_draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("line", self.x, self.y, self.radius)
end

Objects.create_type("ScoreCircle", score_circle)
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
    love.math.setRandomSeed(os.clock())

    self.depth = Room.room_height

    self.player = Objects.grab("Player")
    self:reposition()
end

function score_circle:on_update(dt)
    self.visible = Objects.count_type("Enemy") == 0
    if Vector.distance_between(self.x, self.y, self.player.x, self.player.y) < self.radius and self.visible then
        local wave_manger = Objects.grab("WaveManager")
        wave_manger:wave_start()
        self:reposition()
    end
end

function score_circle:on_draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("line", self.x, self.y, self.radius)

    love.graphics.setColor(1, 0, 0, 0.25)
    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("rough")
    local triangle_angle = math.pi / 32

    local dir_x, dir_y = Vector.direction_between(self.player.x, self.player.y, self.x, self.y)

    local dx1, dy1 = Vector.rotated(dir_x, dir_y, -triangle_angle)
    local dx2, dy2 = self.player.x + dir_x * 40, self.player.y + dir_y * 40
    local dx3, dy3 = Vector.rotated(dir_x, dir_y, triangle_angle)
    local dx4, dy4 = self.player.x + dir_x * 35, self.player.y + dir_y * 35

    dx1 = dx1 * 32
    dy1 = dy1 * 32
    dx3 = dx3 * 32
    dy3 = dy3 * 32

    dx1 = dx1 + self.player.x
    dy1 = dy1 + self.player.y
    dx3 = dx3 + self.player.x
    dy3 = dy3 + self.player.y

    love.graphics.polygon("line", dx1, dy1, dx2, dy2, dx3, dy3, dx4, dy4)
end

Objects.create_type("ScoreCircle", score_circle)
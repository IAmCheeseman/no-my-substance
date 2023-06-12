local collision = require "entities.collide"

local function dissapate(self, dt)
    for i = #self.substance_positions, 1, -1 do
        local v = self.substance_positions[i]

        local vx, vy = Vector.normalized(v.dx, v.dy)
        v.x = v.x + vx * (v.speed / 2) * dt
        v.y = v.y + vy * (v.speed / 2) * dt

        if Vector.length(v.x, v.y) > 10 then
            v.dx = -vx
            v.dy = -vy

            v.x = v.x + v.dx * 2
            v.y = v.y + v.dy * 2
        end

        if Vector.length(v.x, v.y) < 2 then
            table.remove(self.substance_positions, i)
        end
    end

    if #self.substance_positions == 0 then
        Objects.destroy(self)
    end
end

local function default(self, dt)
    for _, v in ipairs(self.substance_positions) do
        local vx, vy = Vector.normalized(v.dx, v.dy)
        v.x = v.x + vx * v.speed * dt
        v.y = v.y + vy * v.speed * dt

        if Vector.length(v.x, v.y) > self.circle_radius then
            v.dx = -vx
            v.dy = -vy

            v.x = v.x + v.dx * 2
            v.y = v.y + v.dy * 2
        end
    end

    local dir_x, dir_y = Vector.direction_between(self.x, self.y, self.player.x, self.player.y)
    local dist = Vector.distance_between(self.x, self.y, self.player.x, self.player.y)

    self.vel_x = math.lerp(self.vel_x, dir_x * self.speed, 5 * dt)
    self.vel_y = math.lerp(self.vel_y, dir_y * self.speed, 5 * dt)

    if dist < 10 then
        self.player:take_damage(5, dir_x, dir_y)
        self.state = dissapate
    end

    if collision.would_collide(self, "Solids", self.vel_x * dt, self.vel_y * dt, { 0, 2, 3 }) then
        self.state = dissapate
    end

    self.x = self.x + self.vel_x * dt
    self.y = self.y + self.vel_y * dt

    self.speed = self.speed + self.accel * dt
end

Objects.create_type("SubstanceBall", {
    substance_sprite = Sprite.new("entities/substance/substance.png", 1, 0),

    substance_positions = {},

    speed = 100,
    accel = 10,

    vel_x = 0,
    vel_y = 0,

    circle_radius = 10,

    sent_message = false,

    state = default,

    on_create = function(self)
        self.substance_sprite.centered = false
        self.substance_sprite.offset_x = self.substance_sprite.texture:getWidth() / 2
        self.substance_sprite.offset_y = self.substance_sprite.texture:getHeight() / 2

        self.player = Objects.grab("Player")

        for i = 1, self.circle_radius * 2 do
            local x, y = Vector.rotated(1, 0, love.math.random(math.pi * 2))
            x = x * love.math.random(self.circle_radius)
            y = y * love.math.random(self.circle_radius)
            table.insert(self.substance_positions, {
                x = x, y = y,
                dx = x, dy = y,
                speed = love.math.random(20, 40),
                r = love.math.random(math.pi * 2)
            })
        end
    end,

    on_update = function(self, dt)
        self:state(dt)

        self.depth = self.y + 16
    end,

    on_draw = function(self)
        love.graphics.setBlendMode("add")
        for _, v in ipairs(self.substance_positions) do
            self.substance_sprite.rotation = v.r
            self.substance_sprite:draw(self.x + v.x, self.y + v.y)
        end
        love.graphics.setBlendMode("alpha")
    end
})
local function absorb(self, dt)
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

    self.ox = math.lerp(self.ox, -(self.x - self.player.x), 20 * dt)
    self.oy = math.lerp(self.oy, -(self.y - self.player.y), 20 * dt)
end

local function default(self, dt) 
    local dist = Vector.distance_between(self.x, self.y, self.player.x, self.player.y)
        
    local target_ox = 0
    local target_oy = 0
    if dist < self.merge_dist then
        local dir_x, dir_y = Vector.direction_between(self.x, self.y, self.player.x, self.player.y)
        target_ox = dir_x * (dist / self.merge_dist) * (dist * 0.6)
        target_oy = dir_y * (dist / self.merge_dist) * (dist * 0.6)
    end
    if dist < 8 then
        self.state = absorb
    end

    self.ox = math.lerp(self.ox, target_ox, 5 * dt)
    self.oy = math.lerp(self.oy, target_oy, 5 * dt)

    for _, v in ipairs(self.substance_positions) do
        local vx, vy = Vector.normalized(v.dx, v.dy)
        v.x = v.x + vx * v.speed * dt
        v.y = v.y + vy * v.speed * dt

        if Vector.length(v.x, v.y) > 10 then
            v.dx = -vx
            v.dy = -vy

            v.x = v.x + v.dx * 2
            v.y = v.y + v.dy * 2
        end
    end
end

Objects.create_type("OriginalSubstance", {
    substance_sprite = Sprite.new("entities/substance/substance.png", 1, 0),

    substance_positions = {},

    ox = 0,
    oy = 0,
    merge_dist = 50,

    state = default,

    on_create = function(self)
        self.substance_sprite.centered = false
        self.substance_sprite.offset_x = self.substance_sprite.texture:getWidth() / 2
        self.substance_sprite.offset_y = self.substance_sprite.texture:getHeight() / 2

        self.player = Objects.grab("Player")

        for i = 1, 30 do
            local x, y = Vector.rotated(1, 0, love.math.random(math.pi * 2))
            x = x * love.math.random(10)
            y = y * love.math.random(10)
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
            self.substance_sprite:draw(self.x + v.x + self.ox, self.y + v.y + self.oy)
        end
        love.graphics.setBlendMode("alpha")
    end
})
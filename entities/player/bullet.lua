local collision = require "entities.collide"

local bullet = {
    sprite = Sprite.new("entities/player/bullet.png", 5, 10),

    hit = {},
    piercing = 3,

    dir_x = 0,
    dir_y = 0,
    speed = 300,
}

function bullet:destroy_with_poof()
    local poof = Objects.instance_at("Poof", self.x + 4, self.y + 4)
    poof.color = { 1, 1, 1, 0.5 }
    poof.sprite.scale_x = 0.5
    poof.sprite.scale_y = 0.5
    Objects.destroy(self)
end

function bullet:on_create()
    self.sprite.rotation = Vector.angle(self.dir_x, self.dir_y)
    self.sprite.centered = false

    self.sprite.offset_y = self.sprite.texture:getHeight() / 2
    self.sprite.offset_x = (self.sprite.texture:getWidth() / self.sprite.frame_count) / 2
end

function bullet:on_update(dt)
    if collision.would_collide(self, "Solids", self.dir_x, self.dir_y, { 0, 2, 3 })
    or self.sprite.frame == self.sprite.frame_count then
        self:destroy_with_poof()
    end

    local count = 0

    Objects.with("Enemy", function(other)
        count = 0
        for _, _ in pairs(self.hit) do
            count = count + 1
        end

        if self.hit[other] ~= nil or count >= self.piercing then
            return
        end

        local dist = Vector.distance_between(self.x, self.y, other.x, other.y)
        local collision_radius = math.max(
            (other.sprite.texture:getWidth() / other.sprite.frame_count) / 2, 
            other.sprite.texture:getHeight() / 2)
        if dist < collision_radius then
            other:take_damage(7, self.dir_x, self.dir_y)

            self.hit[other] = 0
        end
    end)

    if count >= self.piercing then
        Objects.destroy(self)
    end

    local speed = self.speed * (1 - self.sprite.frame / self.sprite.frame_count)

    self.x = self.x + self.dir_x * speed * dt
    self.y = self.y + self.dir_y * speed * dt

    self.depth = self.y + 100
end

function bullet:on_draw()
    local frame = self.sprite:get_frame()
    love.graphics.draw(
        self.sprite.texture, frame,
        self.x, self.y, self.sprite.rotation,
        1, 1,
        self.sprite.offset_x, self.sprite.offset_y)
end

Objects.create_type("Bullet", bullet)
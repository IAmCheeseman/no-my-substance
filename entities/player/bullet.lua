local collision = require "entities.collide"

Objects.create_type("Bullet", {
    sprite = Sprite.new("entities/player/bullet.png", 5, 10),

    dir_x = 0,
    dir_y = 0,
    speed = 300,

    on_create = function(self)
        self.sprite.rotation = Vector.angle(self.dir_x, self.dir_y)
    end,

    on_update = function(self, dt)
        if collision.would_collide(self, "Solids", self.dir_x, self.dir_y, { 0, 2, 3 })
        or self.sprite.frame == self.sprite.frame_count then
            Objects.destroy(self)
        end

        Objects.with("Enemy", function(other)
            local dist = Vector.distance_between(self.x, self.y, other.x, other.y)
            if dist < 12 then
                other:take_damage(7, self.dir_x, self.dir_y)

                Objects.destroy(self)
            end
        end)

        local speed = self.speed * (1 - self.sprite.frame / self.sprite.frame_count)

        self.x = self.x + self.dir_x * speed * dt
        self.y = self.y + self.dir_y * speed * dt

        self.depth = self.y + 100
    end
})
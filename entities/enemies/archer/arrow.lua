local collision = require "entities.collide"

Objects.create_type("ArcherArrow", {
    sprite = Sprite.new("entities/enemies/archer/arrow.png", 1, 0),

    dir_x = 0,
    dir_y = 0,
    speed = 300,

    on_create = function(self)
        self.sprite.rotation = Vector.angle(self.dir_x, self.dir_y)
        self.sprite.centered = false

        self.sprite.offset_y = self.sprite.texture:getHeight() / 2
        self.sprite.offset_x = self.sprite.texture:getWidth() / 2

        self.player = Objects.grab("Player")
    end,

    on_update = function(self, dt)
        if collision.would_collide(self, "Solids", self.dir_x, self.dir_y, { 0, 2, 3 }) then
            Objects.destroy(self)
        end

        local dist = Vector.distance_between(self.x, self.y, self.player.x, self.player.y)
        if dist < 12 then
            self.player:take_damage(2.5, self.dir_x, self.dir_y)
            Objects.destroy(self)
        end

        self.x = self.x + self.dir_x * self.speed * dt
        self.y = self.y + self.dir_y * self.speed * dt

        self.depth = self.y + 100
    end,

    on_draw = function(self)
        love.graphics.draw(
            self.sprite.texture,
            self.x, self.y, self.sprite.rotation,
            1, 1,
            self.sprite.offset_x, self.sprite.offset_y)
    end
})
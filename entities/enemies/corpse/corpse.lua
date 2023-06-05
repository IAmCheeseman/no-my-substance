local collision = require "entities.collide"

Objects.create_type("Corpse", {
    frict = 4,

    vel_x = 0,
    vel_y = 0,

    on_create = function(self)
        self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)
        self.shadow = self.sprite:copy()
    end,
    on_update = function(self, dt)
        self.vel_x = math.lerp(self.vel_x, 0, self.frict * dt)
        self.vel_y = math.lerp(self.vel_y, 0, self.frict * dt)

        collision.move(self, "Solids", self.vel_x * dt, self.vel_y * dt)

        self.depth = self.y
    end,
    on_draw = function(self)
        self.shadow.scale_x = self.sprite.scale_x
        self.shadow.scale_y = -self.sprite.scale_y / 2
        self.shadow.frame = self.sprite.frame

        love.graphics.setColor(0, 0, 0, 0.5)
        self.shadow:draw(self.x, self.y)
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        self.sprite:draw(self.x, self.y)
    end
})
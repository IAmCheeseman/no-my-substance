local collision = require "entities.collide"

local arrow = {
    sprite = Sprite.new("entities/enemies/archer/arrow.png", 1, 0),

    speed = 200,
    damage = 2.5,
}

function arrow:on_create()
    self:call_from_base("on_create")

    self.sprite.centered = false
    
    self.sprite.offset_y = self.sprite.texture:getHeight() / 2
    self.sprite.offset_x = self.sprite.texture:getWidth() / 2
    
    self.player = Objects.grab("Player")
end

function arrow:on_update(dt)
    if collision.would_collide(self, "Solids", self.dir_x, self.dir_y, { 0, 2, 3 }) then
        Objects.destroy(self)
    end
    
    self.sprite.rotation = Vector.angle(self.dir_x, self.dir_y)

    Objects.with(self.collide_with, function(other)
        local dist = Vector.distance_between(self.x, self.y, other.x, other.y)
        if dist < 12 then
            if other:take_damage(self.damage, self.dir_x, self.dir_y) then
                Objects.destroy(self)
            end
        end
    end)
    

    self.x = self.x + self.dir_x * self.speed * dt
    self.y = self.y + self.dir_y * self.speed * dt

    self.depth = self.y + 100
end

function arrow:on_draw()
    love.graphics.draw(
        self.sprite.texture,
        self.x, self.y, self.sprite.rotation,
        1, 1,
        self.sprite.offset_x, self.sprite.offset_y)
end


Objects.create_type_from("ArcherArrow", "Projectile", arrow)
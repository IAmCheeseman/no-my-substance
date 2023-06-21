local collision = require "entities.collide"

local villager_bullet = {
    sprite = Sprite.new("entities/enemies/villager/bullet.png", 5, 10),

    speed = 350,
    damage = 0.75,
}

function villager_bullet:on_create()
    self:call_from_base("on_create")

    self.sprite.centered = false
    
    self.sprite.offset_y = self.sprite.texture:getHeight() / 2
    self.sprite.offset_x = (self.sprite.texture:getWidth() / self.sprite.frame_count) / 2
    
    self.player = Objects.grab("Player")
end

function villager_bullet:on_update(dt)
    if collision.would_collide(self, "Solids", self.dir_x, self.dir_y, { 0, 2, 3 }) or self.sprite.frame == 5 then
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
    

    local speed = self.speed * (1 - self.sprite.frame / self.sprite.frame_count)
    self.x = self.x + self.dir_x * speed * dt
    self.y = self.y + self.dir_y * speed * dt

    self.depth = self.y + 100
end


Objects.create_type_from("VillagerBullet", "Projectile", villager_bullet)
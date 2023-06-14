
local mangler = {
    sprite = Sprite.new("entities/enemies/mangler/mangler.png", 13, 10),

    use_corpse = false,
    use_blood = false,

    pausing = false,
}

function mangler:shoot()
    self.sprite.fps = 10

    local fireball = Objects.instance_at("ManglerFireball", self.x, self.y)
    fireball.dir_x, fireball.dir_y = Vector.direction_between(self.x, self.y, self.player.x, self.player.y)
end

function mangler:on_create()
    self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 4)

    self.player = Objects.grab("Player")

    self:create_timer("pause", self.shoot, 0.5)
end

function mangler:on_update(dt)
    if self.sprite.frame == 6 and not self.pausing then
        self.sprite.fps = 0
        self.timers.pause:start()
        self.pausing = true
    end
    if self.sprite.frame == 13 then
        Objects.destroy(self)
    end
    
    self.sprite.scale_x = self.player.x > self.x and -1 or 1
end

Objects.create_type("Mangler", mangler)
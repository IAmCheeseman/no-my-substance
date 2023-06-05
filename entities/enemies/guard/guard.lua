Objects.create_type_from("Guard", "Enemy", {
    sprite = Sprite.new("entities/enemies/guard/guard.png", 3, 10),
    corpse_sprite = Sprite.new("entities/enemies/guard/guardcorpse.png", 1, 0),

    damage = 0,

    health = 1,
    max_health = 1,

    on_create = function(self)
        self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)

        self:call_from_base("on_create")
    end,
    on_update = function(self, dt)
        self:call_from_base("on_update", dt)

        if Vector.distance_between(self.x, self.y, self.player.x, self.player.y) < 10 then
            local dir_x, dir_y = Vector.direction_between(self.x, self.y, self.player.x, self.player.y)
            self.player.vel_x = self.player.vel_x + dir_x * 300
            self.player.vel_y = self.player.vel_y + dir_y * 300
        end
    end,
})
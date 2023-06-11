Objects.create_type("KnightSword", {
    sprite = Sprite.new("entities/enemies/knight/sword.png", 6, 10),
    idle_animation = Sprite.new_animation(1, 1, 0),
    swing_animation = Sprite.new_animation(2, 6, 20),
    target = nil,

    swing = function(self)
        self.sprite:apply_animation(self.swing_animation)

        local de_x, de_y = Vector.direction_between(self.x, self.y, self.player.x, self.player.y)
        local dir_x, dir_y = Vector.rotated(1, 0, self.sprite.rotation)
        local dist = Vector.distance_between(self.x, self.y, self.player.x, self.player.y)
        local dot = Vector.dot(dir_x, dir_y, de_x, de_y)
        if dot > 0 and dist < 32 then
            self.player:take_damage(4, dir_x, dir_y)
        end
    end,

    on_create = function(self)        
        self.sprite:apply_animation(self.idle_animation)
        self.sprite.offset_x = -5
        self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)
        self.sprite.center = false

        self:create_timer("cooldown", nil, 0.7)

        self.player = Objects.grab("Player")
    end,
    on_update = function(self, dt)
        self.sprite.rotation = Vector.angle_between(self.x, self.y, self.player.x, self.player.y)
        self.sprite.scale_y = self.x > self.player.x and -1 or 1

        self.x = self.target.x
        self.y = self.target.y - self.target.sprite.texture:getHeight() / 2

        self.depth = self.target.depth + 1

        if self.sprite.frame == self.swing_animation.anim_end then -- Swing once
            self.sprite:apply_animation(self.idle_animation)
        end
    end,
    on_draw = function(self)
        self.sprite:draw(self.x, self.y)
    end,
})
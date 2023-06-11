local function fire(self)
    self.sprite.frame = 2
end

Objects.create_type("ArcherBow", {
    sprite = Sprite.new("entities/enemies/archer/bow.png", 2, 0),
    target = nil,

    shoot = function(self)
        self.sprite.frame = 1

        self.timers.charge_up:start()

        local arrow = Objects.instance_at("ArcherArrow", self.x, self.y)
        arrow.dir_x, arrow.dir_y = Vector.direction_between(self.x, self.y, self.player.x, self.player.y)
        arrow.speed = 300
    end,

    on_create = function(self)
        self.sprite.offset_x = -5
        self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)
        self.sprite.center = false

        self:create_timer("charge_up", fire, 0.5)
        self:create_timer("cooldown", nil, 0.7)

        self.player = Objects.grab("Player")
    end,
    on_update = function(self, dt)
        self.sprite.rotation = Vector.angle_between(self.x, self.y, self.player.x, self.player.y)
        self.sprite.scale_y = self.x > self.player.x and -1 or 1

        self.x = self.target.x
        self.y = self.target.y - self.target.sprite.texture:getHeight() / 2

        self.depth = self.target.depth + 1
    end,
    on_draw = function(self)
        self.sprite:draw(self.x, self.y)
    end,
})
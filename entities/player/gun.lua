local shoot_sfx = love.sound.newSoundData("entities/player/shoot.mp3")

Objects.create_type("Gun", {
    sprite = Sprite.new("entities/player/gun.png", 1, 0),
    target = nil,

    on_create = function(self)
        self.target = Objects.grab("Player")
        
        self.sprite.offset_x = -5
        self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)
        self.sprite.center = false

        self:create_timer("cooldown", nil, 0.2)
    end,
    on_update = function(self, dt)
        local mx, my = love.mouse.getPosition()
        self.sprite.rotation = Vector.angle_between(self.x, self.y, mx, my)
        self.sprite.scale_y = self.x > mx and -1 or 1

        self.x = self.target.x
        self.y = self.target.y - self.target.sprite.texture:getHeight() / 2

        self.depth = self.target.depth + 1
    end,
    on_draw = function(self)
        self.sprite:draw(self.x, self.y)
    end,

    on_mouse_press = function(self, _, _, button, _, _)
        if button == 1 and self.timers.cooldown.is_over then            
            local bullet = Objects.instance_at("Bullet", self.x, self.y)
            local mx, my = love.mouse.getPosition()
            bullet.dir_x, bullet.dir_y = Vector.rotated(1, 0, Vector.angle_between(self.x, self.y, mx, my))
            bullet.speed = 600

            self.timers.cooldown:start()

            self.visible = true
            Objects.grab("Hand").visible = false

            local shoot = love.audio.newSource(shoot_sfx)
            shoot:play()
        end
    end
})
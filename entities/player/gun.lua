local gui = require "gui.gui"
local substance = require "substance"
local shoot_sfx = love.sound.newSoundData("entities/player/shoot.mp3")

Objects.create_type("Gun", {
    sprite = Sprite.new("entities/player/gun.png", 1, 0),
    target = nil,

    magazine_size = 12,
    ammo = 12,

    get_ammo_regen_time = function(self)
        local percent_of_forgiveness = self.ammo / self.magazine_size
        percent_of_forgiveness = percent_of_forgiveness * 0.75
        return 0.5 - (0.3 * percent_of_forgiveness)
    end,

    regenerate_ammo = function(self)
        self.ammo = math.clamp(self.ammo + 1, 0, self.magazine_size)
        if self.ammo ~= self.magazine_size then
            self.timers.regenerate_ammo:start(self:get_ammo_regen_time())
        end
    end,

    on_create = function(self)
        self.target = Objects.grab("Player")
        
        self.sprite.offset_x = -5
        -- self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)
        self.sprite.center = false

        self:create_timer("cooldown", nil, 0.1)
        self:create_timer("regenerate_ammo", self.regenerate_ammo, 0.5)
    end,
    on_update = function(self, dt)
        local mx, my = love.mouse.getPosition()
        self.sprite.rotation = Vector.angle_between(self.x, self.y, mx, my)
        self.sprite.scale_y = self.x > mx and -1 or 1

        self.x = self.target.x
        self.y = self.target.y - self.target.sprite.texture:getHeight() / 2

        self.depth = self.target.depth + 1

        self.camera = Objects.grab("Camera")
    end,
    on_draw = function(self)
        self.sprite:draw(self.x, self.y)
    end,

    on_mouse_press = function(self, _, _, button, _, _)
        if button == 1 and not substance.active and self.timers.cooldown.is_over and self.ammo ~= 0 then            
            local mx, my = love.mouse.getPosition()
            local dir_x, dir_y = Vector.rotated(1, 0, Vector.angle_between(self.x, self.y, mx, my))
            local bullet = Objects.instance_at("Bullet", self.x + dir_x * 5, self.y + dir_y * 5)
            bullet.dir_x, bullet.dir_y = dir_x, dir_y
            bullet.speed = 600

            self.timers.cooldown:start()

            self.visible = true
            Objects.grab("Hand").visible = false

            local shoot = love.audio.newSource(shoot_sfx)
            shoot:play()

            self.camera:shake(1, 6, 6, 1, 0.1, false, -dir_x, -dir_y)

            self.ammo = self.ammo - 1

            self.timers.regenerate_ammo:start(self:get_ammo_regen_time())
        end
    end,
})
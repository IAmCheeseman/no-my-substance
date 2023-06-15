local staff = {
    sprite = Sprite.new("entities/enemies/staff/staff.png", 1, 0),
    light = Sprite.new("entities/enemies/staff/stafflight.png", 1, 0),

    light_strength = 0,
    damage_flash_shader = love.graphics.newShader("entities/damageflash.fs"),

    shots = 0,
}

function staff:on_create()
    self:create_timer("shoot", self.start_shoot, self.shoot_cooldown)
    self:create_timer("charge_up", self.shoot, self.windup_time)
    self:create_timer("flash", nil, 0.1)

    self.timers.shoot:start()

    self.sprite.offset_y = self.sprite.texture:getHeight() / 2
    self.light.offset_y = self.light.texture:getHeight() / 2
    self.shadow = self.sprite:copy()

    self.state = self.default
end

function staff:shoot()
    self.light_strength = 0
    self.state = self.default

    if self.shots ~= self.max_shots - 1 then
        self.timers.shoot:start()
        self.shots = self.shots + 1
    end

    self.timers.flash:start()

    local ball = Objects.instance_at("SubstanceBall", self.x, self.y)
    ball.damage = self.damage
end

function staff:charge_up(dt)
    self.light_strength = 1 - self.timers.charge_up.time / self.timers.charge_up.total_time
end

function staff:default(dt)
end

function staff:start_shoot()
    self.state = self.charge_up
    self.timers.charge_up:start()
end

function staff:on_update(dt)
    self:state(dt)
end

function staff:on_draw()
    self.shadow.scale_x = self.sprite.scale_x
    self.shadow.scale_y = -self.sprite.scale_y / 2
    self.shadow.rotation = self.sprite.rotation
    self.shadow.frame = self.sprite.frame

    
    love.graphics.setColor(0, 0, 0, 0.5)
    self.shadow:draw(self.x, self.y)
    love.graphics.setColor(1, 1, 1, 1)
    
    love.graphics.setShader(self.damage_flash_shader)
    self.damage_flash_shader:send("is_on", self.timers.flash.time < 0 and 0 or 1)
    self.sprite:draw(self.x, self.y)
    love.graphics.setShader()

    love.graphics.setBlendMode("add")
    love.graphics.setColor(1, 1, 1, self.light_strength)
    self.light:draw(self.x, self.y)
    love.graphics.setBlendMode("alpha")
end

Objects.create_type("Staff", staff)
local collision = require "entities.collide"

local function dead(self, dt)
    self.sprite:apply_animation(self.dead_animation)

    self.vel_x = math.lerp(self.vel_x, 0, 3 * dt)
    self.vel_y = math.lerp(self.vel_y, 0, 3 * dt)

    collision.move(self, "Solids", self.vel_x * dt, self.vel_y * dt)
end

local function roll(self, dt)
    self.sprite:apply_animation(self.rolling_animation)
    -- self.sprite.rotation = (self.timers.stop_roll.time / self.timers.stop_roll.total_time) * math.pi * 2

    collision.move(self, "Solids", self.vel_x * dt, self.vel_y * dt)
end

local function default(self, dt)
    local input_x, input_y = Vector.get_input_direction("w", "a", "s", "d")
    input_x, input_y = Vector.normalized(input_x, input_y)

    if Vector.length(input_x, input_y) == 0 then
        self.sprite:apply_animation(self.idle_animation)
    else
        self.sprite:apply_animation(self.walking_animation)
    end

    local mouse_x, mouse_y = love.mouse.getPosition()
    self.sprite.scale_x = self.x > mouse_x and -1 or 1

    local nvel_x, nvel_y = Vector.normalized(self.vel_x, self.vel_y)
    local accel_delta = Vector.dot(nvel_x, nvel_y, input_x, input_y) < 0.1 and self.frict or self.accel

    self.vel_x = math.lerp(self.vel_x, input_x * self.speed, accel_delta * dt)
    self.vel_y = math.lerp(self.vel_y, input_y * self.speed, accel_delta * dt)

    collision.move(self, "Solids", self.vel_x * dt, self.vel_y * dt)

    if love.keyboard.isDown("space") and self.timers.roll_cooldown.is_over then
        self.vel_x = input_x * self.roll_speed
        self.vel_y = input_y * self.roll_speed

        self.timers.stop_roll:start()
        self.state = roll
    end
end

Objects.create_type("Player", {
    sprite = Sprite.new("entities/player/player.png", 9, 10),
    idle_animation = Sprite.new_animation(1, 3, 10),
    walking_animation = Sprite.new_animation(4, 6, 15),
    rolling_animation = Sprite.new_animation(7, 7, 0),
    dead_animation = Sprite.new_animation(9, 9, 0),

    damage_flash_shader = love.graphics.newShader("entities/damageflash.fs"),

    health = 10,
    max_health = 10,

    speed = 150,
    roll_speed = 300,
    accel = 10,
    frict = 12,

    x = 50,
    y = 150,

    kb_strength = 300,

    vel_x = 0,
    vel_y = 0,

    state = default,

    take_damage = function(self, damage, kb_x, kb_y)
        if self.timers.iframes.time > 0 then
            return
        end

        self.health = self.health - damage

        if self.health <= 0 then
            Objects.destroy(self.hand)
            self.state = dead
        end

        self.vel_x = self.vel_x + kb_x * self.kb_strength
        self.vel_y = self.vel_y + kb_y * self.kb_strength

        self.timers.iframes:start()
    end,

    stop_roll = function(self)
        self.state = default

        self.vel_x, self.vel_y = Vector.normalized(self.vel_x, self.vel_y)
        self.vel_x = self.vel_x * self.speed
        self.vel_y = self.vel_y * self.speed

        self.sprite.rotation = 0

        self.timers.roll_cooldown:start()
    end,


    on_create = function(self)
        local camera = Objects.grab("Camera")
        camera.tracked = self

        self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)

        self.shadow = self.sprite:copy()

        self:create_timer("stop_roll", self.stop_roll, 0.3)
        self:create_timer("roll_cooldown", nil, 0.75)
        self:create_timer("iframes", nil, 0.5)

        self.hand = Objects.instance_at("Hand", self.x, self.y)
    end,
    on_update = function(self, dt)
        self:state(dt)
        self.depth = self.y

        if love.keyboard.isDown("r") then
            if love.keyboard.isDown("lshift") then
                current_level = 0
            end
            Room.change_to("Level_" .. current_level)
        end
    end,
    on_draw = function(self)
        self.shadow.scale_x = self.sprite.scale_x
        self.shadow.scale_y = -self.sprite.scale_y / 2
        self.shadow.rotation = self.sprite.rotation
        self.shadow.frame = self.sprite.frame

        love.graphics.setColor(0, 0, 0, 0.5)
        self.shadow:draw(self.x, self.y)
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setShader(self.damage_flash_shader)
        self.damage_flash_shader:send("is_on", self.timers.iframes.time < 0 and 0 or 1)
        self.sprite:draw(self.x, self.y)
        love.graphics.setShader()
    end
})
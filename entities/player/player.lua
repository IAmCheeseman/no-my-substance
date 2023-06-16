local gui = require "gui.gui"
local voiceline = require "entities.voicelineplayer"
local collision = require "entities.collide"
local substance = require "substance"

local redo_spray_tan = love.audio.newSource("entities/player/voicelines/redospraytan.mp3", "stream")

local normal_sprite = Sprite.new("entities/player/player.png", 9, 10)
local substance_sprite = Sprite.new("entities/player/playersubstancized.png", 9, 10)

local level_start_lines = {
    [1] = {
        line = redo_spray_tan,
        priority = 0,
        speaker = "Chris",
        subtitle = "Man... I gotta redo my spray tan."
    }
}

local player = {
    sprite = normal_sprite,
    idle_animation = Sprite.new_animation(1, 3, 10),
    walking_animation = Sprite.new_animation(4, 6, 15),
    rolling_animation = Sprite.new_animation(7, 7, 0),
    dead_animation = Sprite.new_animation(9, 9, 0),

    damage_flash_shader = love.graphics.newShader("entities/damageflash.fs"),

    health = 10,
    max_health = 10,

    health_bar_value = 1,
    health_bar_recent_value = 1,

    speed = 150,
    substance_speed = 180,

    roll_speed = 300,
    accel = 10,
    frict = 12,

    x = 50,
    y = 150,

    kb_strength = 300,

    vel_x = 0,
    vel_y = 0,
}

function player:dead(dt)
    self.sprite:apply_animation(self.dead_animation)

    if collision.would_collide(self, "Solids", self.vel_x * dt, self.vel_y * dt) then
        self.vel_x = -self.vel_x
        self.vel_y = -self.vel_y
    end

    self.vel_x = math.lerp(self.vel_x, 0, 3 * dt)
    self.vel_y = math.lerp(self.vel_y, 0, 3 * dt)

    collision.move(self, "Solids", self.vel_x * dt, self.vel_y * dt)
end

function player:roll(dt)
    self.sprite:apply_animation(self.rolling_animation)
    -- self.sprite.rotation = (self.timers.stop_roll.time / self.timers.stop_roll.total_time) * math.pi * 2

    Objects.instance_at("Poof", self.x + 8, self.y)
    collision.move(self, "Solids", self.vel_x * dt, self.vel_y * dt)
end

function player:default(dt)
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

    local speed = self.speed
    if substance.active then
        speed = self.substance_speed
    end

    self.vel_x = math.lerp(self.vel_x, input_x * speed, accel_delta * dt)
    self.vel_y = math.lerp(self.vel_y, input_y * speed, accel_delta * dt)

    if not clip then
        collision.move(self, "Solids", self.vel_x * dt, self.vel_y * dt)
    else
        self.x = self.x + self.vel_x * dt
        self.y = self.y + self.vel_y * dt
    end

    if love.keyboard.isDown("space") and self.timers.roll_cooldown.is_over then
        self.vel_x = input_x * self.roll_speed
        self.vel_y = input_y * self.roll_speed

        self.timers.stop_roll:start()
        self.timers.flicker:start()
        self.state = self.roll
    end
end

function player:start_substance()
    self.timers.substance:start()
    Objects.instance_at("Poof", self.x + 8, self.y)
    self.timers.flicker:start()
end

function player:on_substance_end()
    Objects.instance_at("Poof", self.x + 8, self.y)
    self.timers.flicker:start()
end

function player:take_damage(damage, kb_x, kb_y)
    if not self.timers.iframes.is_over or self.state == self.roll or godmode then
        return false
    end

    local total_damage = damage
    -- if substance.active then
    --     total_damage = total_damage
    -- end

    self.health = self.health - total_damage

    if self.health <= 0 then
        Objects.destroy(self.hand)
        Objects.destroy(self.gun)
        self.state = self.dead
    end

    self.vel_x = self.vel_x + kb_x * self.kb_strength
    self.vel_y = self.vel_y + kb_y * self.kb_strength

    self.timers.iframes:start()

    return true
end

function player:stop_roll()
    self.state = self.default

    self.vel_x, self.vel_y = Vector.normalized(self.vel_x, self.vel_y)
    self.vel_x = self.vel_x * self.speed
    self.vel_y = self.vel_y * self.speed

    self.sprite.rotation = 0

    self.timers.roll_cooldown:start()
end


function player:on_create()
    local camera = Objects.grab("Camera")
    camera.tracked = self

    for _, sprite in ipairs{normal_sprite, substance_sprite} do
        sprite.offset_y = math.floor(sprite.texture:getHeight() / 2)
    end

    self.shadow = normal_sprite:copy()

    self:create_timer("stop_roll", self.stop_roll, 0.3)
    self:create_timer("roll_cooldown", nil, 0.75)
    self:create_timer("iframes", nil, 0.2)
    self:create_timer("substance", self.on_substance_end, substance.time)
    self:create_timer("flicker", nil, 0.15)

    self.hand = Objects.instance_at("Hand", self.x, self.y)
    self.gun = Objects.instance_at("Gun", self.x, self.y)

    self.hand.visible = false

    if level_start_lines[current_level] then
        local line = level_start_lines[current_level]
        voiceline.play_line(line.line, line.priority, line.speaker, line.subtitle)
    end

    self.state = self.default
end

function player:on_update(dt)
    self:state(dt)
    self.depth = self.y

    self.health_bar_value = math.clamp(math.lerp(self.health_bar_value, self.health / self.max_health, 10 * dt), 0, 1)
    self.health_bar_recent_value = math.clamp(math.lerp(self.health_bar_recent_value, self.health / self.max_health, 3 * dt), 0, 1)

    substance.active = not self.timers.substance.is_over

    local mene_count = 0
    Objects.with("Mene", function(other)
        local dist = Vector.distance_between(self.x, self.y, other.x, other.y)
        if dist < 64 then
            mene_count = mene_count + 1
        end
    end)
    substance.amount = math.clamp(substance.amount - mene_count * 10 * dt, 0, substance.max)

    if substance.active then
        substance.amount = (self.timers.substance.time / substance.time) * substance.max
        self.sprite = substance_sprite
    else
        self.sprite = normal_sprite
    end
end

function player:on_draw()
    self.shadow.scale_x = self.sprite.scale_x
    self.shadow.scale_y = -self.sprite.scale_y / 2
    self.shadow.rotation = self.sprite.rotation
    self.shadow.frame = self.sprite.frame

    love.graphics.setColor(0, 0, 0, 0.5)
    self.shadow:draw(self.x, self.y)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setShader(self.damage_flash_shader)
    self.damage_flash_shader:send("is_on", (self.timers.iframes.time < 0 and self.timers.flicker.time < 0) and 0 or 1)
    self.sprite:draw(self.x, self.y)
    love.graphics.setShader()
end

function player:on_key_press(key, _, _)
    if key == "r" and self.state == self.dead then
        Room.reset()
    end

    if key == "e" and substance.unlocked and substance.amount == substance.max then
        self.health = self.max_health
        self.timers.substance:start()
    end

    if key == "m" then
        if love.audio.getVolume() == 0 then
            love.audio.setVolume(1)
        else
            love.audio.setVolume(0)
        end
    end
end

function player:on_gui()
    -- Health
    gui.bar(5, 5, 100, 10, { 0.06, 0.07, 0.12 }, { 1, 1, 1 }, self.health_bar_recent_value)
    gui.bar(5, 5, 100, 10, { 0, 0, 0, 0 }, { 0.64, 0.18, 0.18 }, self.health_bar_value)
    love.graphics.setFont(gui.font)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.print(math.floor(self.health / self.max_health * 100) .. "%", 7, 5)
    -- Substance
    if substance.unlocked or substance.active then
        gui.bar(5, 14, 50, 5, { 0.06, 0.07, 0.12 }, { 0, 1, 1 }, substance.amount / substance.max)
    end

    -- ammo
    if self.gun.timers.regenerate_ammo then
        gui.bar(5, 180 - 13, 48, 10, { 0, 0, 0 }, { 1, 0.8, 0 }, self.gun.ammo / self.gun.magazine_size)

        local ammo_regen = 1 - self.gun.timers.regenerate_ammo.time / self.gun.timers.regenerate_ammo.total_time
        if self.gun.timers.regenerate_ammo.is_over then
            ammo_regen = 1
        end
        gui.bar(5, 180 - 4, 32, 3, { 0, 0, 0 }, { 1, 1, 1 }, ammo_regen)

        love.graphics.setColor(0.4, 0.2, 0, 0.5)
        love.graphics.print(self.gun.ammo .. "/" .. self.gun.magazine_size, 7, 180 - 14)
    end

    -- Death screen
    if self.state == self.dead then
        love.graphics.setFont(gui.font)
        love.graphics.setColor(0, 0, 0, 1)
        local half_height = 180 / 2
        local third_width = 321 / 3

        love.graphics.rectangle("fill", 0, 0, 321, half_height - 22)
        love.graphics.rectangle("fill", 0, half_height + 32, 321, 180)
        love.graphics.rectangle("fill", 0, 0, third_width, 180)
        love.graphics.rectangle("fill", 321 - third_width, 0, 321 - third_width, 180)
        love.graphics.setColor(1, 1, 1, 1)

        gui.outlined_text("DEATH HAS FALLEN UPON YOU", 0, 180 / 2 - 32, 320, "center", { 0, 0, 0 }, { 1, 0.1, 0.3 })
        gui.outlined_text("PRESS ''R'' TO REINCARNATE", 0, 180 / 2 + 32, 320, "center", { 0, 0, 0 }, { 1, 0.1, 0.3 })
    end
end

Objects.create_type("Player", player)
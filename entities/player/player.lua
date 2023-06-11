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

    local speed = self.speed
    if substance.active then
        speed = self.substance_speed
    end

    self.vel_x = math.lerp(self.vel_x, input_x * speed, accel_delta * dt)
    self.vel_y = math.lerp(self.vel_y, input_y * speed, accel_delta * dt)

    collision.move(self, "Solids", self.vel_x * dt, self.vel_y * dt)

    if love.keyboard.isDown("space") and self.timers.roll_cooldown.is_over then
        self.vel_x = input_x * self.roll_speed
        self.vel_y = input_y * self.roll_speed

        self.timers.stop_roll:start()
        self.state = roll
    end
end

Objects.create_type("Player", {
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
    substance_speed = 200,

    roll_speed = 300,
    accel = 10,
    frict = 12,

    x = 50,
    y = 150,

    kb_strength = 300,

    vel_x = 0,
    vel_y = 0,

    state = default,

    start_substance = function(self)
        self.timers.substance:start()
    end,

    take_damage = function(self, damage, kb_x, kb_y)
        if not self.timers.iframes.is_over or self.state == roll or godmode then
            return
        end

        local total_damage = damage
        if substance.active then
            total_damage = total_damage * 2
        end

        self.health = self.health - total_damage

        if self.health <= 0 then
            Objects.destroy(self.hand)
            Objects.destroy(self.gun)
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

        for _, sprite in ipairs{normal_sprite, substance_sprite} do
            sprite.offset_y = math.floor(sprite.texture:getHeight() / 2)
        end

        self.shadow = normal_sprite:copy()

        self:create_timer("stop_roll", self.stop_roll, 0.3)
        self:create_timer("roll_cooldown", nil, 0.75)
        self:create_timer("iframes", nil, 0.2)
        self:create_timer("substance", nil, substance.time)

        self.hand = Objects.instance_at("Hand", self.x, self.y)
        self.gun = Objects.instance_at("Gun", self.x, self.y)

        self.hand.visible = false
    
        if level_start_lines[current_level] then
            local line = level_start_lines[current_level]
            voiceline.play_line(line.line, line.priority, line.speaker, line.subtitle)
        end
    end,
    on_update = function(self, dt)
        self:state(dt)
        self.depth = self.y

        if love.keyboard.isDown("r") and self.state == dead then
            Room.reset()
        end

        if love.keyboard.isDown("e") and substance.unlocked then
            self.timers.substance:start()
        end

        self.health_bar_value = math.clamp(math.lerp(self.health_bar_value, self.health / self.max_health, 10 * dt), 0, 1)
        self.health_bar_recent_value = math.clamp(math.lerp(self.health_bar_recent_value, self.health / self.max_health, 3 * dt), 0, 1)

        substance.active = not self.timers.substance.is_over
        if substance.active then
            substance.amount = (self.timers.substance.time / substance.time) * substance.max
            self.sprite = substance_sprite
        else
            self.sprite = normal_sprite
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
    end,

    on_gui = function(self)
        gui.bar(5, 5, 100, 10, { 0.06, 0.07, 0.12 }, { 1, 1, 1 }, self.health_bar_recent_value)
        gui.bar(5, 5, 100, 10, { 0, 0, 0, 0 }, { 0.64, 0.18, 0.18 }, self.health_bar_value)
        
        love.graphics.setFont(gui.font)
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.print(math.floor(self.health / self.max_health * 100) .. "%", 7, 5)

        if substance.unlocked or substance.active then
            gui.bar(5, 14, 50, 5, { 0.06, 0.07, 0.12 }, { 0, 1, 1 }, substance.amount / substance.max)
        end

        if self.state == dead then
            love.graphics.setFont(gui.font)
            love.graphics.setColor(1, 1, 1, 1)
            gui.outlined_text("DEATH HAS FALLEN UPON YOU", 0, 180 / 2, 320, "center", { 0, 0, 0 }, { 1, 0.1, 0.3 })
            gui.outlined_text("PRESS \"R\" TO REINCARNATE", 0, 180 / 2 + 8, 320, "center", { 0, 0, 0 }, { 1, 0.1, 0.3 })
        end
    end
})
local substance = require "substance"
local voiceline = require "entities.voicelineplayer"
local collision = require "entities.collide"

local hurt_sounds = {
    love.audio.newSource("entities/enemies/hurt1.mp3", "stream"),
    love.audio.newSource("entities/enemies/hurt2.mp3", "stream"),
    love.audio.newSource("entities/enemies/hurt3.mp3", "stream"),
}

local death = love.audio.newSource("entities/enemies/nooo.mp3", "stream")
local substance_death = love.audio.newSource("entities/enemies/nomysubstance.mp3", "stream")

local function flee(self, dt)
    self.sprite:apply_animation(self.walk_animation)

    local dir_x, dir_y = Vector.direction_between(self.x, self.y, self.target.x, self.target.y)

    self.vel_x = math.lerp(self.vel_x, -dir_x * self.flee_speed, self.accel * dt)
    self.vel_y = math.lerp(self.vel_y, -dir_y * self.flee_speed, self.accel * dt)

    self.sprite.scale_x = self.target.x < self.x and -1 or 1

    self.x = self.x + self.vel_x * dt
    self.y = self.y + self.vel_y * dt
end

local function attack(self, dt)
    self.sprite:apply_animation(self.attack_animation)

    self.vel_x = math.lerp(self.vel_x, 0, self.accel * dt)
    self.vel_y = math.lerp(self.vel_y, 0, self.accel * dt)

    self.x = self.x + self.vel_x * dt
    self.y = self.y + self.vel_y * dt
end

local function charge(self, dt)
    self.sprite:apply_animation(self.walk_animation)

    local tx, ty = self.target.x, self.target.y
    tx = tx + math.cos(self.rot) * 80
    ty = ty + math.sin(self.rot) * 80

    local dir_x, dir_y = Vector.direction_between(self.x, self.y, tx, ty)

    self.vel_x = math.lerp(self.vel_x, dir_x * self.speed, self.accel * dt)
    self.vel_y = math.lerp(self.vel_y, dir_y * self.speed, self.accel * dt)

    self.sprite.scale_x = self.target.x < self.x and -1 or 1

    self.x = self.x + self.vel_x * dt
    self.y = self.y + self.vel_y * dt

    local dist_to_player = Vector.distance_between(self.x, self.y, self.player.x, self.player.y)
    if self.timers.spin.is_over then
        self.state = attack
        self.timers.attack:start()
    end

    self.rot = self.rot + dt
end

local function default(self, dt)
    local dist_to_player = Vector.distance_between(self.x, self.y, self.player.x, self.player.y)
    if dist_to_player < 190 then
        self.state = charge
    end
end


Objects.create_type_from("Mene", "Enemy", {
    sprite = Sprite.new("entities/enemies/mene/mene.png", 7, 10),
    corpse_sprite = Sprite.new("entities/enemies/knight/knightcorpse.png", 1, 0),
    idle_animation = Sprite.new_animation(1, 7, 10),
    walk_animation = Sprite.new_animation(1, 7, 10),
    attack_animation = Sprite.new_animation(7, 7, 0),

    speed = 110,
    flee_speed = 180,
    accel = 3,

    health = 40,

    rot = 0,

    state = default,

    on_attack_over = function(self)
        if self.state == default then
            return
        end
        self.state = flee
        self.timers.flee:start()
    end,
    on_flee_over = function(self)
        if self.state == default then
            return
        end
        self.state = charge
        self.timers.spin:start()
    end,

    on_create = function(self)
        self.sprite:apply_animation(self.idle_animation)
        self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)

        self:create_timer("spin", nil, 5)
        self:create_timer("attack", self.on_attack_over, 0.5)
        self:create_timer("flee", self.on_flee_over, 0.25)

        self:call_from_base("on_create")
    end,
    on_update = function(self, dt)
        self:call_from_base("on_update", dt)
        self:state(dt)
    end,

    on_death = function(self)        
        if love.math.random() < 0.2 then
            local death_sfx = substance.unlocked and substance_death or death
            local subtitle = substance.unlocked and "NOOO! MY SUBSTANCE!" or "NOOO!"
            voiceline.play_line(death_sfx, 0, "Knight", subtitle)
        end
    end,

    on_hurt = function(self)
        if love.math.random() < 0.5 then
            hurt_sounds[love.math.random(1, #hurt_sounds)]:play()
        end
    end
})
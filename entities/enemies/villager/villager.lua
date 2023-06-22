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

local villager = {
    sprite = Sprite.new("entities/enemies/villager/villager.png", 6, 10),
    corpse_sprite = Sprite.new("entities/enemies/villager/villagercorpse.png", 1, 0),
    idle_animation = Sprite.new_animation(1, 3, 10),
    walk_animation = Sprite.new_animation(4, 6, 10),

    gun_recoil = 70,

    max_shots = 5,
    current_shots = 0,

    speed = 100,
    accel = 3,
    frict = 6,

    state = nil,
}

function villager:charge(dt)
    self.sprite:apply_animation(self.walk_animation)

    local dir_x, dir_y = Vector.direction_between(self.x, self.y, self.target.x, self.target.y)--Room.get_path("Solids", self.x, self.y, self.player.x, self.player.y)

    self.vel_x = math.lerp(self.vel_x, dir_x * self.speed, self.accel * dt)
    self.vel_y = math.lerp(self.vel_y, dir_y * self.speed, self.accel * dt)

    self.sprite.scale_x = self.target.x < self.x and -1 or 1

    collision.move(self, "Solids", self.vel_x * dt, self.vel_y * dt)
end

function villager:default(dt)
    local dist_to_player = Vector.distance_between(self.x, self.y, self.player.x, self.player.y)
    if dist_to_player < 190 then
        self.state = self.charge
    end
end

function villager:on_attack_over()
    if self.state == self.default or self.current_shots > self.max_shots then
        self.current_shots = 0
        self.timers.attack:start(5)
        return
    end
    self.gun:shoot()

    local push_x, push_y = Vector.direction_between(self.x, self.y, self.player.x, self.player.y)
    self.vel_x = self.vel_x + -push_x * self.gun_recoil
    self.vel_y = self.vel_y + -push_y * self.gun_recoil

    self.current_shots = self.current_shots + 1

    self.timers.attack:start(0.1)
end

function villager:on_create()
    self.sprite:apply_animation(self.idle_animation)
    self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)

    self:create_timer("attack", self.on_attack_over, 0.1)

    self:call_from_base("on_create")

    self.gun = Objects.instance_at("Uzi", self.x, self.y)
    self.gun.target = self

    self.state = Objects.count_type("WaveManager") == 0 and self.default or self.charge

    self.timers.attack:start()
end
function villager:on_update(dt)
    self:call_from_base("on_update", dt)
    self:state(dt)
end

function villager:on_death()
    Objects.destroy(self.gun)
    
    if love.math.random() < 0.2 then
        local death_sfx = substance.is_unlocked() and substance_death or death
        local subtitle = substance.is_unlocked() and "NOOO! MY SUBSTANCE!" or "NOOO!"
        voiceline.play_line(death_sfx, 0, "Villager", subtitle)
    end
end

function villager:on_hurt()
    if love.math.random() < 0.5 then
        hurt_sounds[love.math.random(1, #hurt_sounds)]:play()
    end
end


Objects.create_type_from("Villager", "Enemy", villager)
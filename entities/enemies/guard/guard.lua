local voiceline = require "entities.voicelineplayer"

local turn_back = love.audio.newSource("entities/enemies/guard/turnback.mp3", "stream")
local death = love.audio.newSource("entities/enemies/guard/death.mp3", "stream")

Objects.create_type_from("Guard", "Enemy", {
    sprite = Sprite.new("entities/enemies/guard/guard.png", 3, 10),
    corpse_sprite = Sprite.new("entities/enemies/guard/guardcorpse.png", 1, 0),

    damage = 0,

    health = 1,
    max_health = 1,

    warned = false,

    on_create = function(self)
        self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)

        self:call_from_base("on_create")
    end,
    on_update = function(self, dt)
        self:call_from_base("on_update", dt)

        local dist = Vector.distance_between(self.x, self.y, self.player.x, self.player.y)

        if dist < 140 and not self.warned then
            voiceline.play_line(turn_back, 1, "Guard", "Turn back! Get away!")

            self.warned = true
        end

        if dist < 10 then
            local dir_x, dir_y = Vector.direction_between(self.x, self.y, self.player.x, self.player.y)
            self.player.vel_x = self.player.vel_x + dir_x * 300
            self.player.vel_y = self.player.vel_y + dir_y * 300
        end
    end,

    on_death = function()
        voiceline.play_line(death, 0, "Guard", "Auuughh")
    end
})
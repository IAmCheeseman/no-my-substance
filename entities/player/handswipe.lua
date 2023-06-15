local substance = require "substance"

local swing = love.audio.newSource("entities/player/punchswing.mp3", "stream")
local hit = love.audio.newSource("entities/player/punchhit.mp3", "stream")

local hand_swipe = {
    sprite = Sprite.new("entities/player/handswipe.png", 6, 20),

    hit = {},
    kb_amount = 1.2,

    damage = 2,
    substance_damage = 15,
}

function hand_swipe:on_create()
    self.sprite.offset_x = math.floor((-self.sprite.texture:getWidth() / self.sprite.frame_count) / 4)
    self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)
    self.sprite.center = false
    self.sprite.frame = 2

    local mx, my = love.mouse.getPosition()
    self.sprite.rotation = Vector.angle_between(self.x, self.y, mx, my)

    swing:play()

    local dir_x, dir_y = Vector.direction_between(self.x, self.y, love.mouse.getPosition())

    Objects.with("Enemy", function(other)
        if self.hit[other] ~= nil then
            return
        end

        local de_x, de_y = Vector.direction_between(self.x, self.y, other.x, other.y)
        local dist = Vector.distance_between(self.x, self.y, other.x, other.y)
        local dot = Vector.dot(dir_x, dir_y, de_x, de_y)
        if dot > 0 and dist < 50 then
            local damage = self.damage
            if substance.active then
                damage = self.substance_damage
            end

            other:take_damage(damage, dir_x * self.kb_amount, dir_y * self.kb_amount)

            self.hit[other] = 0

            hit:play()
        end
    end)

    Objects.with("Projectile", function(other)
        if self.hit[other] ~= nil then
            return
        end

        local de_x, de_y = Vector.direction_between(self.x, self.y, other.x, other.y)
        local dist = Vector.distance_between(self.x, self.y, other.x, other.y)
        local dot = Vector.dot(dir_x, dir_y, de_x, de_y)
        if dot > 0 and dist < 50 then
            local damage = self.damage
            if substance.active then
                damage = self.substance_damage
            end

            other.dir_x = -other.dir_x * 1.3
            other.dir_y = -other.dir_y * 1.3
            other.collides_with = "Enemy"

            self.hit[other] = 0

            hit:play()
        end
    end)
end

function hand_swipe:on_update(dt)
    if self.sprite.frame == 1 then
        Objects.destroy(self)
    end
end

Objects.create_type("HandSwipe", hand_swipe)
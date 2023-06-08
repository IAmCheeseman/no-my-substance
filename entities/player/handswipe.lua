
Objects.create_type("HandSwipe", {
    sprite = Sprite.new("entities/player/handswipe.png", 6, 20),

    hit = {},

    on_create = function(self)
        self.sprite.offset_x = math.floor((-self.sprite.texture:getWidth() / self.sprite.frame_count) / 4)
        self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)
        self.sprite.center = false
        self.sprite.frame = 2

        local mx, my = love.mouse.getPosition()
        self.sprite.rotation = Vector.angle_between(self.x, self.y, mx, my)
    end,

    on_update = function(self, dt)
        local dir_x, dir_y = Vector.direction_between(self.x, self.y, love.mouse.getPosition())

        Objects.with("Enemy", function(other)
            if self.hit[other] ~= nil then
                return
            end

            local de_x, de_y = Vector.direction_between(self.x, self.y, other.x, other.y)
            local dist = Vector.distance_between(self.x, self.y, other.x, other.y)
            local dot = Vector.dot(dir_x, dir_y, de_x, de_y)
            if dot > 0 and dist < 40 then
                other:take_damage(5, dir_x, dir_y)

                self.hit[other] = 0
            end
        end)

        if self.sprite.frame == 1 then
            Objects.destroy(self)
        end
    end
})
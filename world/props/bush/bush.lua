local bush = {
    sprite = Sprite.new("world/props/bush/bush.png", 2, 0)
}

function bush:on_create()
    self:call_from_base("on_create")
    if Room.get_cell("Solids", self.x, self.y + 8) ~= 1 then
        self.shadow = self.sprite:copy()
    end
    self.player = Objects.grab("Player")
end

function bush:destroy()
    self.depth = 0
    self.sprite.frame = 2
    self.sway_amount = 0
    self.shadow = nil
end

function bush:on_update(dt)
    self:call_from_base("on_update", dt)

    if Vector.distance_between(self.x, self.y, self.player.x, self.player.y) < 12 then
        self:destroy()
    end

    for _, v in ipairs({"Enemy", "Bullet"}) do
        Objects.with(v, function(other)
            if Vector.distance_between(self.x, self.y, other.x, other.y) < 12 then
                self:destroy()
            end
        end)
    end
end

function bush:on_draw()
    if self.shadow then
        self.shadow.scale_x = self.sprite.scale_x
        self.shadow.scale_y = -self.sprite.scale_y / 2
        self.shadow.rotation = self.sprite.rotation
        self.shadow.frame = self.sprite.frame

        love.graphics.setColor(0, 0, 0, 0.5)
        self.shadow:draw(self.x, self.y)
        love.graphics.setColor(1, 1, 1, 1)
    end
    self.sprite:draw(self.x, self.y)
end

Objects.create_type_from("Bush", "SwayingProp", bush)
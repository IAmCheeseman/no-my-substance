
local prop = {
    sway_amount = 0.1,
    sway_time = 0.5,
    time = 0,
}

function prop:on_create()
    self.sprite.center = false
    self.sprite.offset_x = (self.sprite.texture:getWidth() / self.sprite.frame_count) / 2
    self.sprite.offset_y = self.sprite.texture:getHeight()

    self.time = love.math.random(0, 10)

    self.depth = self.y
end

function prop:on_update(dt)
    self.time = self.time + dt

    self.sprite.skew_x = math.sin(self.time * self.sway_time) * self.sway_amount
end

Objects.create_type("SwayingProp", prop)
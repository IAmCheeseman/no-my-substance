
local poof = {
    sprite = Sprite.new("entities/poof/poof.png", 6, 10)
}

function poof:on_create()
    self.sprite.rotation = love.math.random(math.pi * 2)

    self.sprite.centered = true
    self.sprite.offset_x = (self.sprite.texture:getWidth() / self.sprite.frame_count) / 2
    self.sprite.offset_y = self.sprite.texture:getHeight() / 2
    self.sprite.fps = love.math.random(8, 12)
end

function poof:on_update(dt)
    if self.sprite.frame == 6 then
        Objects.destroy(self)
    end
end

Objects.create_type("Poof", poof)
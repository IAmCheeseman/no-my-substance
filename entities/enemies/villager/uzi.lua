local shoot_sfx = love.sound.newSoundData("entities/enemies/villager/shoot.mp3")

local uzi = {
    sprite = Sprite.new("entities/enemies/villager/uzi.png", 1, 0),
    target = nil,
}

function uzi:shoot()
    local shoot = love.audio.newSource(shoot_sfx) 
    shoot:play()

    self.timers.charge_up:start()
    local spread = 30
    local angle = math.deg(Vector.angle_between(self.x, self.y, self.player.x, self.player.y)) + love.math.random(-spread, spread)
    local dir_x, dir_y = math.cos(math.rad(angle)), math.sin(math.rad(angle))

    local arrow = Objects.instance_at("VillagerBullet", self.x + dir_x * 20, self.y + dir_y * 20)

    arrow.dir_x, arrow.dir_y = dir_x, dir_y
end

function uzi:on_create()
    self.sprite.offset_x = -5
    self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)
    self.sprite.center = false

    self:create_timer("charge_up", fire, 0.5)
    self:create_timer("cooldown", nil, 0.7)

    self.player = Objects.grab("Player")
end

function uzi:on_update(dt)
    self.sprite.rotation = Vector.angle_between(self.x, self.y, self.player.x, self.player.y)
    self.sprite.scale_y = self.x > self.player.x and -1 or 1

    self.x = self.target.x
    self.y = self.target.y - self.target.sprite.texture:getHeight() / 2

    self.depth = self.target.depth + 1
end

function uzi:on_draw()
    self.sprite:draw(self.x, self.y)
end

Objects.create_type("Uzi", uzi)
local collision = require "entities.collide"

local function charge(self, dt)
    self.sprite:apply_animation(self.walk_animation)

    local dir_x, dir_y = Vector.direction_between(self.x, self.y, self.target.x, self.target.y)

    self.vel_x = math.lerp(self.vel_x, dir_x * self.speed, self.accel * dt)
    self.vel_y = math.lerp(self.vel_y, dir_y * self.speed, self.accel * dt)

    self.sprite.scale_x = self.target.x < self.x and -1 or 1

    collision.move(self, "Solids", self.vel_x * dt, self.vel_y * dt)
end

local function default(self, dt)
    local dist_to_player = Vector.distance_between(self.x, self.y, self.player.x, self.player.y)
    if dist_to_player < 190 then
        self.state = charge
    end
end


Objects.create_type_from("Knight", "Enemy", {
    sprite = Sprite.new("entities/enemies/knight/knight.png", 7, 10),
    corpse_sprite = Sprite.new("entities/enemies/knight/knightcorpse.png", 1, 0),
    idle_animation = Sprite.new_animation(1, 3, 10),
    walk_animation = Sprite.new_animation(4, 6, 10),

    speed = 90,
    accel = 3,

    state = default,

    on_create = function(self)
        self.sprite:apply_animation(self.idle_animation)
        self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)

        self:call_from_base("on_create")
    end,
    on_update = function(self, dt)
        self:call_from_base("on_update", dt)
        self:state(dt)
    end,
})
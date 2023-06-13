
Objects.create_type("ManglerSpawner", {
    rate = 3,

    get_mangler_position = function(self)
        local x, y = self.player.x, self.player.y
        local dist = love.math.random(64, 100)
        local rot = love.math.random(math.pi * 2)
        
        x = x + math.cos(rot) * dist
        y = y + math.sin(rot) * dist

        if Room.get_cell("Solids", x, y) ~= 2 then
            return self:get_mangler_position()
        end

        return x, y
    end,

    spawn_mangler = function(self)
        self.timers.spawn_mangler:start()

        local x, y = self:get_mangler_position()
        Objects.instance_at("Mangler", x, y)
    end,
    
    on_create = function(self)
        self:create_timer("spawn_mangler", self.spawn_mangler, self.rate)
        self.timers.spawn_mangler:start()

        self.player = Objects.grab("Player")
    end
})

Objects.create_type("Mangler", {
    sprite = Sprite.new("entities/enemies/mangler/mangler.png", 13, 10),

    use_corpse = false,
    use_blood = false,

    pausing = false,

    shoot = function(self)
        self.sprite.fps = 10

        local fireball = Objects.instance_at("ManglerFireball", self.x, self.y)
        fireball.dir_x, fireball.dir_y = Vector.direction_between(self.x, self.y, self.player.x, self.player.y)
    end,

    on_create = function(self)
        self.player = Objects.grab("Player")

        self:create_timer("pause", self.shoot, 0.5)
    end,
    on_update = function(self, dt)
        if self.sprite.frame == 6 and not self.pausing then
            self.sprite.fps = 0
            self.timers.pause:start()
            self.pausing = true
        end 
        if self.sprite.frame == 13 then
            Objects.destroy(self)
        end       
    end
})
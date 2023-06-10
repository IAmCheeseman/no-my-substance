
Objects.create_type("Enemy", {
    sprite = nil,
    corpse_sprite = nil,
    target = nil,

    damage_flash_shader = love.graphics.newShader("entities/damageflash.fs"),

    damage = 2.5,
    health = 10,
    max_health = 10,

    push_speed = 300,
    kb_strength = 300,
    
    vel_x = 0,
    vel_y = 0,

    take_damage = function(self, damage, kb_x, kb_y)
        self.health = self.health - damage
        
        if self.health <= 0 then
            print(Objects.count_type("Enemy"))
            local corpse = Objects.instance_at("Corpse", self.x, self.y)
            corpse.vel_x = kb_x * self.kb_strength
            corpse.vel_y = kb_y * self.kb_strength
            corpse.sprite = self.corpse_sprite

            Objects.destroy(self)

            if self.on_death then
                self:on_death()
            end
        end

        self.vel_x = self.vel_x + kb_x * self.kb_strength
        self.vel_y = self.vel_y + kb_y * self.kb_strength

        self.timers.iframes:start()
    end,

    on_create = function(self)
        self.shadow = self.sprite:copy()

        self.player = Objects.grab("Player")

        self:create_timer("iframes", nil, 0.2)
    end,
    on_update = function(self, dt)
        if player_invisible then
            self.target = self
            return
        end

        local push_x = 0
        local push_y = 0

        self.target = self.player
        local dist = Vector.distance_between(self.x, self.y, self.target.x, self.target.y)
        local dist_player = Vector.mdistance_between(self.x / 16, self.y / 16, self.player.x / 16, self.player.y / 16)
        Objects.with("PriorityPoint", function(other)
            local other_dist = Vector.distance_between(self.x, self.y, other.x, other.y)
            local other_dist_player = Vector.mdistance_between(other.x / 16, other.y / 16, self.player.x / 16, self.player.y / 16)
            if other_dist < dist and other_dist_player < dist_player then
                dist = other_dist
                self.target = other
            end
        end)

        Objects.with("Enemy", function(other)
            if other == self then
                return
            end
            
            local dist = Vector.distance_between(self.x, self.y, other.x, other.y)
            if dist > 10 then
                return
            end

            local dx, dy = Vector.direction_between(self.x, self.y, other.x, other.y)
            push_x = push_x - dx
            push_y = push_y - dy
        end)

        push_x, push_y = Vector.normalized(push_x, push_y)

        self.vel_x = self.vel_x + push_x * self.push_speed * dt
        self.vel_y = self.vel_y + push_y * self.push_speed * dt

        self.depth = self.y

        if Vector.distance_between(self.x, self.y, self.player.x, self.player.y) < 8 and self.damage > 0 then
            local kb_x, kb_y = Vector.direction_between(self.x, self.y, self.player.x, self.player.y)
            self.player:take_damage(self.damage, kb_x, kb_y)
        end
    end,
    on_draw = function(self)
        self.shadow.scale_x = self.sprite.scale_x
        self.shadow.scale_y = -self.sprite.scale_y / 2
        self.shadow.frame = self.sprite.frame

        love.graphics.setColor(0, 0, 0, 0.5)
        self.shadow:draw(self.x, self.y)
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.setShader(self.damage_flash_shader)
        self.damage_flash_shader:send("is_on", self.timers.iframes.time < 0 and 0 or 1)
        self.sprite:draw(self.x, self.y)
        love.graphics.setShader()
    end
})
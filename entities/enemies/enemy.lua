
Objects.create_type("Enemy", {
    sprite = nil,
    target = nil,

    push_speed = 300,
    
    vel_x = 0,
    vel_y = 0,

    on_create = function(self)
        self.shadow = self.sprite:copy()

        self.player = Objects.grab_object("Player")
    end,
    on_update = function(self, dt)
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
    end,
    on_draw = function(self)
        self.shadow.scale_x = self.sprite.scale_x
        self.shadow.scale_y = -self.sprite.scale_y / 2
        self.shadow.frame = self.sprite.frame

        love.graphics.setColor(0, 0, 0, 0.5)
        self.shadow:draw(self.x, self.y)
        love.graphics.setColor(1, 1, 1, 1)
        self.sprite:draw(self.x, self.y)
    end
})
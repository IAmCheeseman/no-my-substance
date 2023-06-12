local substance = require "substance"

Objects.create_type("Hand", {
    sprite = Sprite.new("entities/player/hand.png", 6, 10),
    idle_animation = Sprite.new_animation(1, 1, 0),
    swing_animation = Sprite.new_animation(2, 6, 20),
    target = nil,

    on_create = function(self)
        self.target = Objects.grab("Player")
        
        self.sprite:apply_animation(self.idle_animation)
        self.sprite.offset_x = -5
        self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)
        self.sprite.center = false

        self:create_timer("cooldown", nil, 0.7)
    end,
    on_update = function(self, dt)
        local mx, my = love.mouse.getPosition()
        self.sprite.rotation = Vector.angle_between(self.x, self.y, mx, my)
        self.sprite.scale_y = self.x < mx and -1 or 1

        self.x = self.target.x
        self.y = self.target.y - self.target.sprite.texture:getHeight() / 2

        self.depth = self.target.depth + 1

        if self.sprite.frame == self.swing_animation.anim_end then -- Swing once
            self.sprite:apply_animation(self.idle_animation)
        end

    end,
    on_draw = function(self)
        self.sprite:draw(self.x, self.y)
    end,

    on_mouse_press = function(self, _, _, button, _, _)
        if (button == 2 or substance.active) and self.timers.cooldown.is_over then
            self.sprite:apply_animation(self.swing_animation)
            
            local swipe = Objects.instance_at("HandSwipe", self.x, self.y)

            self.timers.cooldown:start()

            self.visible = true
            Objects.grab("Gun").visible = false
        end
    end
})
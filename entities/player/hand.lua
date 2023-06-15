local substance = require "substance"

local hand = {
    sprite = Sprite.new("entities/player/hand.png", 6, 10),
    idle_animation = Sprite.new_animation(1, 1, 0),
    swing_animation = Sprite.new_animation(2, 6, 20),
    target = nil,

    cooldown = 0.5,
    substance_cooldown = 0.3,
}

function hand:on_create()
    self.target = Objects.grab("Player")
    
    self.sprite:apply_animation(self.idle_animation)
    self.sprite.offset_x = -5
    self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)
    self.sprite.center = false

    self:create_timer("cooldown", nil, 0.5)
end

function hand:on_update(dt)
    local mx, my = love.mouse.getPosition()
    self.sprite.rotation = Vector.angle_between(self.x, self.y, mx, my)
    self.sprite.scale_y = self.x < mx and -1 or 1

    self.x = self.target.x
    self.y = self.target.y - self.target.sprite.texture:getHeight() / 2

    self.depth = self.target.depth + 1

    if self.sprite.frame == self.swing_animation.anim_end then -- Swing once
        self.sprite:apply_animation(self.idle_animation)
    end

end

function hand:on_draw()
    self.sprite:draw(self.x, self.y)
end

function hand:on_mouse_press(_, _, button, _, _)
    if (button == 2 or substance.active) and self.timers.cooldown.is_over then
        self.sprite:apply_animation(self.swing_animation)
        
        local swipe = Objects.instance_at("HandSwipe", self.x, self.y)

        self.timers.cooldown:start(substance.active and self.substance_cooldown or self.cooldown)

        self.visible = true
        
        local gun = Objects.grab("Gun")
        gun.visible = false
    end
end

Objects.create_type("Hand", hand)
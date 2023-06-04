Objects.create_type("Hand", {
    sprite = Sprite.new("entities/player/hand.png", 5, 0),
    target = nil,

    on_create = function(self)
        self.target = Objects.grab("Player")
    end,
    on_update = function(self, dt)
        self.sprite.rotation = Vector.angle_between(self.x, self.y, love.mouse.getPosition())
        
        self.x = self.target.x
        self.y = self.target.y

        print(self.x, self.y)
    end
})
Objects.create_type("GuardBoat", {
    sprite = Sprite.new("entities/enemies/guard/guardboat.png", 1, 0),

    on_create = function(self)
        self.sprite.center = false
    end
})
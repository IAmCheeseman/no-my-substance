Objects.create_type("SubstanceGiver", {
    sprite = Sprite.new("world/props/substancegiver/substancegiver.png", 1, 0),

    on_create = function(self)
        Objects.instance_at("OriginalSubstance", self.x, self.y - 12)
    end
})
Objects.create_type("SubstanceGiver", {
    sprite = Sprite.new("world/props/substancegiver/substancegiver.png", 2, 0),

    on_create = function(self)
        Objects.instance_at("OriginalSubstance", self.x + 2.5, self.y - 12)
    end
})
local rapid_mangler = {
    sprite = Sprite.new("entities/enemies/mangler/radpidmangler.png", 13, 10),
    
    shot_count = 1
}



function rapid_mangler:shoot()
    self:call_from_base("shoot")

    if self.shot_count ~= 3 then
        self.shot_count = self.shot_count + 1
        self.timers.shoot:start()
    end
end

function rapid_mangler:on_create()
    self:call_from_base("on_create")

    self:create_timer("shoot", self.shoot, 0.1)
end


Objects.create_type_from("RapidMangler", "Mangler", rapid_mangler)
local projectile = {
    dir_x = 0,
    dir_y = 0,

    collide_with = "Player",

    effect_name = "",
    effect_interval = 0.25,
}

function projectile:on_create()
    self:create_timer("effect", self.spawn_effect, self.effect_interval)
end

function projectile:start_effect()
    self:spawn_effect()
end

function projectile:spawn_effect()
    if self.effect_name ~= "" then
        local effect = Objects.instance_at(self.effect_name, self.x, self.y + 8)
        effect.sprite.scale_x = 0.5
        effect.sprite.scale_y = 0.5

        if self.effect_interval then
            self.timers.effect:start(self.effect_interval)
        end
    end
end

Objects.create_type("Projectile", projectile)
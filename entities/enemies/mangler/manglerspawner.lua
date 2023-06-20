local mangler_spawner = {
    rate = 3,

    can_spawn_rapid = false,
    rapid_chance = 0.5,
}

function mangler_spawner:check_position(x, y)
    return Room.get_cell("Solids", x, y) == 2 and
            Room.get_cell("Solids", x + 8, y) == 2 and 
            Room.get_cell("Solids", x - 8, y) == 2 and
            Room.get_cell("Solids", x, y + 8) == 2 and
            Room.get_cell("Solids", x, y - 8) == 2
end

function mangler_spawner:get_mangler_position(tries)
    tries = tries or 0

    if tries > 100 then
        return nil, nil
    end

    local x, y = self.player.x, self.player.y
    local dist = love.math.random(64, 100)
    local rot = love.math.random(math.pi * 2)
    
    x = x + math.cos(rot) * dist
    y = y + math.sin(rot) * dist

    if not self:check_position(x, y) then
        return self:get_mangler_position(tries + 1)
    end

    return x, y
end

function mangler_spawner:spawn_mangler()
    self.timers.spawn_mangler:start()

    local x, y = self:get_mangler_position()
    if x == nil and y == nil then
        return
    end

    if self.can_spawn_rapid and love.math.random() < self.rapid_chance then
        Objects.instance_at("RapidMangler", x, y)
    else
        Objects.instance_at("Mangler", x, y)
    end
end

function mangler_spawner:on_create()
    self:create_timer("spawn_mangler", self.spawn_mangler, self.rate)
    self.timers.spawn_mangler:start()

    self.player = Objects.grab("Player")
end

Objects.create_type("ManglerSpawner", mangler_spawner)
local mangler_spawner = {
    rate = 3,
}

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

    if Room.get_cell("Solids", x, y) ~= 2 then
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
    Objects.instance_at("Mangler", x, y)
end

function mangler_spawner:on_create()
    self:create_timer("spawn_mangler", self.spawn_mangler, self.rate)
    self.timers.spawn_mangler:start()

    self.player = Objects.grab("Player")
end

Objects.create_type("ManglerSpawner", mangler_spawner)
local logger = require "gui.log"
local gui = require "gui.gui"

local function create_enemy(enemy, starting_wave, chance)
    return {
        type = enemy,
        starting_wave = starting_wave,
        chance = chance,
    }
end

local enemies = {
    create_enemy("Knight",   1,  100),
    create_enemy("Archer",   3,  25),
    create_enemy("Mene",     7,  5),
    create_enemy("Villager", 10, 10),
    -- create_enemy("Firemage", 15, 0.05),
    -- create_enemy("Bodybuilder", 20, 0.025),
}

local wave_manager = {
    current_wave = 0,
    enemies_spawned = 0,
    enemy_kills = 0,
}

function wave_manager:get_target_enemy_count()
    return math.floor(5 + math.atan(self.current_wave / 10) * 70)
end

function wave_manager:get_random_enemy()
    return enemies[love.math.random(1, #enemies)]
end

function wave_manager:select_enemy()
    local enemy = self:get_random_enemy()
    while love.math.random(0, 100) > enemy.chance or 
            self.current_wave < enemy.starting_wave do
        enemy = self:get_random_enemy()
    end
    return enemy.type
end

function wave_manager:get_spawnable_spot(depth)
    depth = depth or 0

    if depth > 20 then
        return nil, nil
    end

    local px, py = self.player.x, self.player.y
    local angle = love.math.random(math.pi * 2)
    local distance = 190

    local x, y = px + math.cos(angle) * distance, py + math.sin(angle) * distance
    if Room.get_cell("Solids", x, y) ~= 0 then
        return self:get_spawnable_spot(depth + 1)
    end
    return x, y
end

function wave_manager:on_enemy_death(enemy)
    self.enemy_kills = self.enemy_kills + 1
end

function wave_manager:spawn_enemy()
    if self.enemies_spawned < self:get_target_enemy_count() - 1 then
        self.timers.spawn_enemy:start()
    end

    local x, y = self:get_spawnable_spot()
    if x == nil and y == nil then
        return
    end
    local enemy = Objects.instance_at(self:select_enemy(), x, y)
    enemy.vel_x = 0
    enemy.vel_y = 0
    table.insert(enemy.on_death_connections, { self, self.on_enemy_death })

    self.enemies_spawned = self.enemies_spawned + 1
end

function wave_manager:wave_start()
    self.current_wave = self.current_wave + 1
    self.enemy_kills = 0
    self.enemies_spawned = 0
    self.timers.spawn_enemy:start()

    logger.log_message("Wave #" .. self.current_wave)
end

function wave_manager:on_create()
    self.player = Objects.grab("Player")
    
    self:create_timer("spawn_enemy", self.spawn_enemy, 0.2)
    self:create_timer("wave", self.wave_start, 3)
    
    self.timers.wave:start()
end

function wave_manager:on_update(dt)
    if self.enemy_kills >= self:get_target_enemy_count() and self.timers.wave.is_over then
        self.timers.wave:start()
    end
end

function wave_manager:on_gui()
    local progress = self.enemy_kills / self:get_target_enemy_count()
    if not self.timers.wave.is_over then
        progress = self.timers.wave.time / self.timers.wave.total_time
    end
    gui.bar(5, 150, 96, 10, { 0.06, 0.07, 0.12 }, { 0, 1, 1 }, progress)
    love.graphics.setColor(0.2, 0.6, 0.7)

    local enemy_kills = ", " .. tostring(self.enemy_kills) .. "/" .. self:get_target_enemy_count()

    love.graphics.printf("WAVE #" .. self.current_wave .. enemy_kills, 5, 150, 96, "center")
end

Objects.create_type("WaveManager", wave_manager)
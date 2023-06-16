local camera = {
    persistent = true,
    
    x = 0,
    y = 0,

    wx = 0,
    wy = 0,

    sx = 0,
    sy = 0,

    tracked = nil,

    track_speed = 25,

    priority = 0, 
    strength_min = 0, 
    strength_max = 0,
    jump_frequency = 0,
    shake_time = 0,
    strength_reduce = false, 
    shake_dir_x = 0, 
    shake_dir_y = 0,
}

function camera:jump()
    local dir_x, dir_y = self.shake_dir_x, self.shake_dir_y
    if dir_x == 0 and dir_y == 0 then
        local angle = love.math.random(math.pi * 2)
        dir_x = math.cos(angle)
        dir_y = math.sin(angle)
    end

    dir_x = dir_x * love.math.random(self.strength_min, self.strength_max)
    dir_y = dir_y * love.math.random(self.strength_min, self.strength_max)

    if self.strength_reduce then
        local percent_over = self.timers.shake.time / self.timers.shake.total_time
        dir_x = dir_x * percent_over
        dir_y = dir_y * percent_over
    end

    self.sx = dir_x
    self.sy = dir_y

    self.timers.jump:start(self.jump_frequency)
end

function camera:shake_end()
    self.priority = 0
    self.strength_min = 0
    self.strength_max = 0
    self.timers.jump:stop()
end

function camera:on_create()
    self:create_timer("jump", self.jump, 0.1)
    self:create_timer("shake", self.shake_end, 1)
end

function camera:on_update(dt)
    if self.tracked == nil then
        return
    end

    local mx, my = love.mouse.getPosition()
    mx = mx - self.tracked.x
    my = my - self.tracked.y

    self.wx = mx * 0.06
    self.wy = my * 0.06

    self.sx = math.lerp(self.sx, 0, 25 * dt)
    self.sy = math.lerp(self.sy, 0, 25 * dt)

    self.x = math.lerp(self.x, self.tracked.x + self.wx,       self.track_speed * dt)
    self.y = math.lerp(self.y, (self.tracked.y - 8) + self.wy, self.track_speed * dt)

    Game.camera_x = self.x + self.sx
    Game.camera_y = self.y + self.sy
end

function camera:shake( 
    priority, 
    strength_min, strength_max,
    jump_frequency, shake_time,
    strength_reduce, 
    shake_dir_x, shake_dir_y)

    strength_reduce = strength_reduce or false
    shake_dir_x = shake_dir_x or 0
    shake_dir_y = shake_dir_y or 0

    if priority < self.priority then
        return
    end

    self.priority = priority
    self.strength_min = strength_min
    self.strength_max = strength_max
    self.jump_frequency = jump_frequency
    self.shake_time = shake_time
    self.strength_reduce = strength_reduce
    self.shake_dir_x = shake_dir_x
    self.shake_dir_y = shake_dir_y

    self.timers.shake:start(shake_time)
    self.jump(self)
end

Objects.create_type("Camera", camera)
Objects.initial_object("Camera")
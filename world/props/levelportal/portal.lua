local logger = require "gui.log"
local save_data = require "savedata"

local woosh = love.audio.newSource("world/props/levelportal/woosh.mp3", "stream")

local level_portal = {
    sprite = Sprite.new("world/props/levelportal/portal.png", 1, 0),
    vortex_upper = Sprite.new("world/props/levelportal/vortex.png", 1, 0),
    vortex_lower = Sprite.new("world/props/levelportal/vortex.png", 1, 0),
    depth = -1,

    open = false,
    previous_open = false,
}

function level_portal:on_create()
    self.player = Objects.grab("Player")

    self.vortex_upper.offset_x = self.vortex_upper.texture:getWidth() / 2
    self.vortex_upper.offset_y = self.vortex_upper.texture:getHeight() / 2
    self.vortex_lower.offset_x = self.vortex_lower.texture:getWidth() / 2
    self.vortex_lower.offset_y = self.vortex_lower.texture:getHeight() / 2

    self.vortex_lower.rotation = math.pi / 4
end

function level_portal:on_update(dt)
    self.open = Objects.count_type("Enemy") == 0

    if self.open ~= self.previous_open then
        logger.log_message("Level cleared!")
    end

    if Vector.distance_between(self.player.x, self.player.y, self.x, self.y) < 8 and self.open then
        current_level = current_level + 1
        if not Room.is_room_in_range(current_level) then
            current_level = 1
        end
        Room.change_to(get_current_level())
        save_data.save()

        woosh:play()
    end

    self.vortex_upper.rotation = self.vortex_upper.rotation + dt * 3
    self.vortex_lower.rotation = self.vortex_lower.rotation + dt * 3.5

    self.previous_open = self.open
end

function level_portal:on_draw()
    self.sprite:draw(self.x, self.y)

    if self.open then
        love.graphics.setBlendMode("add")
        love.graphics.setColor(0, 0, 1)
        self.vortex_lower:draw(self.x + 8, self.y + 6)
        love.graphics.setColor(0, 1, 1)
        self.vortex_upper:draw(self.x + 8, self.y + 6)
        love.graphics.setBlendMode("alpha")
    end
end

Objects.create_type("LevelPortal", level_portal)
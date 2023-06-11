local module = {}

local blood_manager = nil
local blood_queue = {}

local blood_image = love.graphics.newImage("world/blood/blood.png")
local blood_sprite_count = 3
local blood_sprite_size = blood_image:getWidth() / blood_sprite_count

function module.new(x, y, angle)
    table.insert(blood_queue, {
        x = x, y = y,
        angle = angle
    })
end

if not Objects.does_type_exist("BloodManager") then
    Objects.create_type("BloodManager", {
        persistent = true,

        on_create = function(self)
            blood_manager = self

            self:on_room_change("Level_1")
        end,

        on_room_change = function(self, room_name)
            if self.canvas ~= nil then
                self.canvas:release()
            end
            print(Room.room_width, Room.room_height)
            self.canvas = love.graphics.newCanvas(Room.room_width, Room.room_height)
            self.depth = -Room.room_height
        end,

        on_draw = function(self)
            if self.canvas == nil then
                return
            end

            love.graphics.push()
            love.graphics.origin()
            self.canvas:renderTo(function()
                for _, blood in ipairs(blood_queue) do
                    local sprite_index = math.floor(love.math.random(blood_sprite_count))
                    local quad = love.graphics.newQuad(
                        blood_sprite_size * sprite_index, 0,
                        blood_sprite_size, blood_sprite_size,
                        blood_image:getDimensions())
                    
                    love.graphics.draw(
                        blood_image, 
                        quad, 
                        blood.x, blood.y, blood.angle, 
                        1, 1, 
                        blood_sprite_size / 2, blood_sprite_size / 2)
                end
                blood_queue = {}
            end)
            love.graphics.pop()

            love.graphics.draw(self.canvas, 0, 0)
        end
    })
end

return module
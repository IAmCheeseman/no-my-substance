local house_sprites = {
    {
        shadow_offset = -9,
        sprites = {
            Sprite.new("world/village/house1.png", 1, 0),
            Sprite.new("world/village/house2.png", 1, 0),
            Sprite.new("world/village/house3.png", 1, 0),
            Sprite.new("world/village/house4.png", 1, 0),
            Sprite.new("world/village/house5.png", 1, 0),
        }
    },
    {
        shadow_offset = -8,
        sprites = {
            Sprite.new("world/village/house6.png", 1, 0),
            Sprite.new("world/village/house7.png", 1, 0),
            Sprite.new("world/village/house8.png", 1, 0),
            Sprite.new("world/village/house9.png", 1, 0),
            Sprite.new("world/village/house10.png", 1, 0),
        }
    },
    {
        shadow_offset = -15,
        sprites = {
            Sprite.new("world/village/house11.png", 1, 0),
            Sprite.new("world/village/house12.png", 1, 0),
            Sprite.new("world/village/house13.png", 1, 0),
            Sprite.new("world/village/house14.png", 1, 0),
            Sprite.new("world/village/house15.png", 1, 0),
        }
    }
}

local function on_create(self)
    self.depth = self.y

    self.sprite = self.sprites[love.math.random(1, #self.sprites)]
    -- local image_data = love.image.newImageData(self.sprite.path)
    
    -- local sx, sy =  self.x - self.sprite.offset_x, (self.y - self.sprite.offset_y + 8) / 2
    -- local x, y = sx, sy

    -- local sprite_width, sprite_height = self.sprite.texture:getWidth() - 1, self.sprite.texture:getHeight() - 1

    -- for w = 1, self.sprite.texture:getWidth() / 16 do
    --     for h = 1, ((self.sprite.texture:getHeight() + 1) / 16) / 2 do
    --         local _, _, _, a = image_data:getPixel(
    --             math.min(w * 16 - 8, sprite_width), 
    --             math.min(h * 16 - 8, sprite_height))
    --         if Room.get_cell("Solids", x, y) == 0 and a ~= 0 then
    --             Room.set_cell("Solids", 5, x, y)
    --         end

    --         y = y + 16
    --     end

    --     y = sy
    --     x = x + 16
    -- end

    self.player = Objects.grab("Player")
end

local function on_update(self, dt)
    local x, y = self.x, self.y - self.sprite.texture:getHeight() / 2

    local dist = Vector.distance_between(x, y, self.player.x, self.player.y)
    local target_alpha = math.clamp(dist / self.sprite.texture:getWidth(), 0.2, 1)

    Objects.with("Enemy", function(other)
        local dist = Vector.distance_between(x, y, other.x, other.y)
        target_alpha = target_alpha * math.clamp(dist / self.sprite.texture:getWidth(), 0.2, 1)
    end)

    target_alpha = math.clamp(target_alpha, 0.2, 1)

    self.alpha = math.lerp(self.alpha, target_alpha, 20 * dt)
end

local function on_draw(self)
    love.graphics.setColor(0, 0, 0, 0.5)
    self.shadow:draw(self.x, self.y)
    love.graphics.setColor(1, 1, 1, self.alpha)
    self.sprite:draw(self.x, self.y)
end

for i, v in ipairs(house_sprites) do
    for _, sprite in ipairs(v.sprites) do
        sprite.center = false
        sprite.offset_x = sprite.texture:getWidth() / 2
        sprite.offset_y = sprite.texture:getHeight()
    end

    local house = {
        sprites = v.sprites,
        shadow = v.sprites[1]:copy(),
        alpha = 1,

        on_create = on_create,
        on_update = on_update,
        on_draw = on_draw,
    }

    house.shadow.offset_y = house.shadow.texture:getHeight() + v.shadow_offset
    house.shadow.scale_y = -0.5

    Objects.create_type("House" .. tostring(i), house)
end
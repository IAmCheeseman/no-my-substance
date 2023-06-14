local module = {}

-- module.font = love.graphics.newFont("gui/pixelated.ttf", 8)
module.font = love.graphics.newImageFont("gui/font.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%`'*#=[]")
module.font:setFilter("nearest", "nearest")

function module.bar(sx, sy, ex, ey, bgc, fgc, v)
    love.graphics.setColor(bgc[1], bgc[2], bgc[3], bgc[4] or 1)
    love.graphics.rectangle("fill", sx, sy, ex, ey)

    love.graphics.setColor(fgc[1], fgc[2], fgc[3], fgc[4] or 1)

    local vx = ((ex - sx) * v) + (sx - 2)

    love.graphics.rectangle("fill", sx + 1, sy + 1, vx, ey - 2)
end

function module.outlined_text(what, x, y, limit, align, outlinec, textc, size)
    size = size or 1

    love.graphics.setColor(outlinec[1], outlinec[2], outlinec[3], outlinec[4] or 1)

    for i = 0, size do
        love.graphics.printf(what, x - (size - i), y, limit, align)
        love.graphics.printf(what, x + (size - i), y, limit, align)
        love.graphics.printf(what, x, y - (size - i), limit, align)
        love.graphics.printf(what, x, y + (size - i), limit, align)

        love.graphics.printf(what, x - (size - i), y - (size - i), limit, align)
        love.graphics.printf(what, x + (size - i), y + (size - i), limit, align)
        love.graphics.printf(what, x - (size - i), y + (size - i), limit, align)
        love.graphics.printf(what, x + (size - i), y - (size - i), limit, align)
    end

    love.graphics.setColor(textc[1], textc[2], textc[3], textc[4] or 1)
    love.graphics.printf(what, x, y, limit, align)
end

if not Objects.does_type_exist("Label") then
    local label = {
        text = "Label",
        font = module.font,
        foreground_color = { 1, 1, 1 },
    }

    function label:on_gui()
        love.graphics.setFont(self.font)

        local tw, th = self.font:getWidth(self.text), self.font:getHeight(self.text)

        love.graphics.setColor(self.foreground_color[1], self.foreground_color[2], self.foreground_color[3])
        love.graphics.print(self.text, self.x - tw / 2, self.y - th / 2)
    end

    Objects.create_type("Label", label)
end

if not Objects.does_type_exist("Button") then
    local button = {
        text = "Button",
        font = module.font,
        text_padding = 3,
        hover_scale = 1.25,
        scale = 1,
        background_color = { 0, 0, 0 },
        foreground_color = { 1, 1, 1 },
    }

    function button:get_size()
        local tw, th = self.font:getWidth(self.text), self.font:getHeight(self.text)
        return tw + self.text_padding, th + self.text_padding
    end

    function button:is_hovered()
        local mx, my = love.mouse.getWindowPosition()
        local w, h = self:get_size()
        local x, y = self.x - w / 2, self.y - h / 2

        return mx > x and mx < x + w and
                my > y and my < y + h
    end

    function button:on_create()
        self.text = string.upper(self.text)
    end

    function button:on_update(dt)
        local hovered = self:is_hovered()

        if hovered then
            self.target_scale = self.hover_scale
        else
            self.target_scale = 1
        end

        self.scale = math.lerp(self.scale, self.target_scale, 20 * dt)
    end

    function button:on_mouse_press(_, _, button, _, _)
        if button == 1 and self:is_hovered() and self.on_click then
            self.on_click()
        end
    end

    function button:on_gui()
        love.graphics.setFont(self.font)
        
        local tw, th = self:get_size()

        local w, h = tw * self.scale, th * self.scale
        local x, y = self.x - w / 2, self.y - h / 2

        love.graphics.setColor(self.background_color[1], self.background_color[2], self.background_color[3])
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(self.foreground_color[1], self.foreground_color[2], self.foreground_color[3])
        love.graphics.print(self.text, x + self.text_padding / 2, y + self.text_padding / 2, 0, self.scale, self.scale)
    end

    Objects.create_type("Button", button)
end

return module
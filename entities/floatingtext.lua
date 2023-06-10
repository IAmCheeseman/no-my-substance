Objects.create_type("FloatingText", {
    text = "Default",
    color = {},

    on_create = function(self)
        self.text = string.upper(self.text)
    end,
    on_draw = function(self)
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.print(self.text, self.x, self.y + 2)
        love.graphics.setColor(self.color.r, self.color.g, self.color.b, 1)
        love.graphics.print(self.text, self.x, self.y)
    end
})
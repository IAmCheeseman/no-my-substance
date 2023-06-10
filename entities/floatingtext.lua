Objects.create_type("FloatingText", {
    text = "Default",
    color = {},
    show_distance = 0,

    on_create = function(self)
        self.text = string.upper(self.text)

        self.player = Objects.grab("Player")
    end,
    on_draw = function(self)
        local dist = Vector.distance_between(self.x, self.y, self.player.x, self.player.y)
        local alpha = math.clamp(1 - dist / self.show_distance, 0, 1)

        love.graphics.setColor(0, 0, 0, 0.5 * alpha)
        love.graphics.print(self.text, self.x, self.y + 2)
        love.graphics.setColor(self.color.r, self.color.g, self.color.b, 1 * alpha)
        love.graphics.print(self.text, self.x, self.y)
    end
})
local floating_text = {
    text = "Default",
    color = {},
    show_distance = 0,
}

function floating_text:on_create()
    self.text = string.upper(self.text)

    self.player = Objects.grab("Player")
end

function floating_text:on_draw()
    local dist = Vector.distance_between(self.x, self.y, self.player.x, self.player.y)
    local alpha = math.clamp(1 - dist / self.show_distance, 0, 1)

    love.graphics.setColor(0, 0, 0, 0.5 * alpha)
    love.graphics.print(self.text, self.x, self.y + 2)
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, 1 * alpha)
    love.graphics.print(self.text, self.x, self.y)
end

Objects.create_type("FloatingText", floating_text)
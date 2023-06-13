
Objects.create_type("Mouse", {
    persistent = true,

    mouse_sprite = Sprite.new("gui/mouse/mouse.png", 1, 0),

    on_create = function(self)
        love.mouse.setVisible(false)
    end,

    on_gui = function(self)
        self.mouse_sprite:draw(love.mouse.getWindowPosition())
    end
})

Objects.instance("Mouse")
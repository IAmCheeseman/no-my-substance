
local mouse = {
    persistent = true,
    depth = 100,
    mouse_sprite = Sprite.new("gui/mouse/mouse.png", 1, 0),
}

function mouse:on_create()
    love.mouse.setVisible(false)
end

function mouse:on_gui()
    self.mouse_sprite:draw(love.mouse.getWindowPosition())
end

Objects.create_type("Mouse", mouse)

Objects.initial_object("Mouse")

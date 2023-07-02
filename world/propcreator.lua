local prop_creator = {
    entities = {},
    entity_tiles = {},
    entity_chances = {},
}

function prop_creator:on_create()
    local w, h = Room.room_width / 16, Room.room_height / 16

    for x = 1, w do
        for y = 1, h do
            local cell = Room.get_cell_l("Solids", x, y)
            
            for i, v in ipairs(self.entity_tiles) do
                if v == cell and love.math.random() < self.entity_chances[i] then
                    Objects.instance_at(self.entities[i], x * 16 - 8, y * 16 + 8)
                end
            end
        end
    end
end

Objects.create_type("PropCreator", prop_creator)

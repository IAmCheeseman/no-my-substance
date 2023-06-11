local module = {}

local function can_walk_on_cell(cell, valid_cells)
    -- 0 is empty, 3 is bridges
    for _, v in ipairs(valid_cells) do
        if cell == v then
            return true
        end
    end
    return false
end

--TODO: MAKE `valid_cells` NOT SUCK
function module.move(object, with, mx, my, valid_cells)
    valid_cells = valid_cells or Room.valid_cells
    local check_x = object.x + mx
    local check_y = object.y + my
    if can_walk_on_cell(Room.get_cell(with, check_x, object.y), valid_cells) then
        object.x = object.x + mx
    end
    if can_walk_on_cell(Room.get_cell(with, object.x, check_y), valid_cells) then
        object.y = object.y + my
    end
end

function module.would_collide(object, with, mx, my, valid_cells)
    valid_cells = valid_cells or { 0, 3 }
    local check_x = object.x + mx
    local check_y = object.y + my
    return not can_walk_on_cell(Room.get_cell(with, check_x, check_y), valid_cells)
end

return module
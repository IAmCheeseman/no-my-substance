local module = {}

local function can_walk_on_cell(cell)
    -- 0 is empty, 3 is bridges
    return cell == 0 or cell == 3
end

function module.move(object, with, mx, my)
    local check_x = object.x + mx
    local check_y = object.y + my
    if can_walk_on_cell(Room.get_cell(with, check_x, object.y)) then
        object.x = object.x + mx
    end
    if can_walk_on_cell(Room.get_cell(with, object.x, check_y)) then
        object.y = object.y + my
    end
end

return module
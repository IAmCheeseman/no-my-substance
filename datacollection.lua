local data_collection = {}

data_collection.data = {
    levels_attempted = {},
    deaths = {},
    times = {},
    finish_time = 0,
}

local function set_default(arr, index, default_val)
    if arr[index] == nil then
        arr[index] = default_val
    end
end

function data_collection:initialize()
    local i = 1
    while Room.is_room_in_range(i) do
        set_default(data_collection.data.levels_attempted, i, false)
        set_default(data_collection.data.deaths, i, 0)
        set_default(data_collection.data.times, i, 0)

        i = i + 1
    end
end

function data_collection:entered_level()
    data_collection.data.levels_attempted[current_level] = true
    data_collection:write_data()
end

function data_collection:add_death()
    local key = current_level
    data_collection.data.deaths[key] = data_collection.data.deaths[key] + 1
    data_collection:write_data()
end

function data_collection:add_level_time(level, time)
    data_collection.data.times[level] = time
    data_collection:write_data()
end

function data_collection:add_finish_time()
    data_collection.data.finish_time = 1
    data_collection:write_data()
end

function data_collection:write_data()
    local data_str = ""

    data_str = data_str .. "Game completion time: " .. data_collection.data.finish_time

    local i = 1
    while Room.is_room_in_range(i) do
        data_str = data_str .. "\n Level_" .. i .. ":"
        data_str = data_str .. "\n\tAttempted: " .. (data_collection.data.levels_attempted[i] and "yes" or "no")
        data_str = data_str .. "\n\tCompletion time: " .. data_collection.data.times[i]
        data_str = data_str .. "\n\tDeaths: " .. data_collection.data.deaths[i]

        i = i + 1
    end

    love.filesystem.write("statistics.txt", data_str)
end

return data_collection
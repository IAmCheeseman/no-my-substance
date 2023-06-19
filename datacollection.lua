local data_collection = {}

local data = {
    levels_attempted = {},
    deaths = {},
    times = {},
    finish_time = 0,
}


function data_collection:initialize()
    local i = 1
    while Room.is_room_in_range(i) do
        data.levels_attempted[i] = false
        data.deaths[i] = 0
        data.times[i] = 0

        i = i + 1
    end
end

function data_collection:entered_level()
    data.levels_attempted[current_level] = true
    data_collection:write_data()
end

function data_collection:add_death()
    local key = current_level
    data.deaths[key] = data.deaths[key] + 1
    data_collection:write_data()
end

function data_collection:add_level_time(level, time)
    data.times[level] = time
    data_collection:write_data()
end

function data_collection:add_finish_time()
    data.finish_time = 1
    data_collection:write_data()
end

function data_collection:write_data()
    local data_str = ""

    data_str = data_str .. "Game completion time: " .. data.finish_time

    local i = 1
    while Room.is_room_in_range(i) do
        data_str = data_str .. "\n Level_" .. i .. ":"
        data_str = data_str .. "\n\tAttempted: " .. (data.levels_attempted[i] and "yes" or "no")
        data_str = data_str .. "\n\tCompletion time: " .. data.times[i]
        data_str = data_str .. "\n\tDeaths: " .. data.deaths[i]

        i = i + 1
    end

    love.filesystem.write("statistics.txt", data_str)
end

return data_collection
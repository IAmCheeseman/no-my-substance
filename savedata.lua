local substance = require "substance"

local save_data = {}

local save_path = "save.txt"

local function split(str)
    local t = {}
    for segment in string.gmatch(str, "([^%s]+)") do
        table.insert(t, segment)
    end
    return t
end

local function toboolean(bool)
    return bool == "true"
end

local mapping = {
    ["substanceunlocked"] = {
        name = "unlocked",
        tab = substance,
        conv = toboolean,
    },
    ["substanceamount"] = {
        name = "amount",
        tab = substance,
        conv = tonumber,
    },
    ["currentlevel"] = {
        name = "current_level",
        tab = _G,
        conv = tonumber,
    }
}

function save_data.load()
    local file_data = love.filesystem.read(save_path)
    if file_data == nil then
        return
    end
    local data = split(file_data)

    local i = 1
    while i < #data do
        local identifier = data[i]
        local value = data[i + 1]

        local map = mapping[identifier]
        map.tab[map.name] = map.conv(value)

        i = i + 2
    end
end

function save_data.save()
    local save = ""
    save = save .. " substanceunlocked " .. tostring(substance.unlocked)
    save = save .. " substanceamount " .. tostring(substance.amount)
    save = save .. " currentlevel " .. tostring(current_level)
    love.filesystem.write(save_path, save)
end

function save_data.clear()
    love.filesystem.remove(save_path)
end

return save_data
local substance = require "substance"
local data_collection = require "datacollection"
local json = require "json.json"

local save_data = {}

local save_path = "save.txt"

local mapping = {
    ["substanceunlocked"] = {
        name = "unlocked",
        tab = substance,
    },
    ["substanceamount"] = {
        name = "amount",
        tab = substance,
    },
    ["currentlevel"] = {
        name = "current_level",
        tab = _G,
    },
    ["datalevelattempted"] = {
        name = "levels_attempted",
        tab = data_collection.data,
    },
    ["dataleveldeaths"] = {
        name = "deaths",
        tab = data_collection.data,
    },
    ["dataleveltimes"] = {
        name = "times",
        tab = data_collection.data,
    }
}

function save_data.load()
    local file_data = love.filesystem.read(save_path)
    if file_data == nil then
        return
    end
    local save_json = love.data.decode("string", "base64", file_data)
    local data = json.decode(save_json)
    print(save_json)

    for k, v in pairs(data) do
        local map = mapping[k]
        map.tab[map.name] = v
    end
end

function save_data.save()
    local save = {}
    save.substanceunlocked = substance.unlocked
    save.substanceamount = substance.amount
    save.currentlevel = current_level
    save.datalevelattempted = data_collection.data.levels_attempted
    save.dataleveldeaths = data_collection.data.deaths
    save.dataleveltimes = data_collection.data.times

    local encoded = love.data.encode("string", "base64", json.encode(save))
    love.filesystem.write(save_path, encoded)
end

function save_data.clear()
    love.filesystem.remove(save_path)
end

return save_data
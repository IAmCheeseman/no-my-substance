
local excluded_dirs = {
    "/.git",
    "/base",
}

local excluded_files = {
    "/main.lua",
    "/conf.lua",
    "/definetypes.lua",
}

local function is_excluded(dir, exclude_list)
    for i, v in ipairs(exclude_list) do
        if v == dir then
            return true
        end
    end
    return false
end

local function recurse_and_require(path)
    local files = love.filesystem.getDirectoryItems(path)

    for i, v in ipairs(files) do
        local file = path .. "/" .. v
        local info = love.filesystem.getInfo(file)
        if info then
            if info.type == "file" and not is_excluded(file, excluded_files) then
                if string.find(file, ".lua") then
                    require(string.gsub(file, ".lua$", ""))
                    print(file)
                end
            elseif info.type == "directory" and not is_excluded(file, excluded_dirs) then
                recurse_and_require(file)
            end
        end
    end
end

recurse_and_require("")


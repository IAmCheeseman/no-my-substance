local data_collection = require "datacollection"

local data_collector = {
    persistent = true,
    time = 0,
    level_start_time = 0,
}

local last_level = 1

function data_collector:on_update(dt)
    self.time = self.time + dt
end

function data_collector:on_room_change(room)
    if current_level ~= last_level then
        data_collection:add_level_time(last_level, self.time - self.level_start_time)

        last_level = current_level
        data_collection:entered_level()
        self.level_start_time = self.time
    end
end

Objects.create_type("DataCollector", data_collector)
Objects.initial_object("DataCollector")
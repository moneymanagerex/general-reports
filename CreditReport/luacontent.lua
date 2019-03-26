--  TODO: Update limits in line 2 (order based on sorted accounts; number of entries must match SQL text).
local limits = {100, 500};
local index = 1;
local base_total = 0;

function handle_record(record)
    record:set("CREDIT", limits[index]);
    record:set("AVAILABLE", credit + record:get("BALANCE"));
    index = index + 1;
    base_total = base_total + record:get("BASEBAL");
end

function complete(result)
    result:set("BASE_TOTAL", base_total);
end

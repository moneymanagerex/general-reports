--  TODO: Update limits in line 2 (order based on sorted accounts; number of entries must match SQL text).
local limits = {100, 500};
local index = 1;
local base_total = 0;

function handle_record(record)
    local prefix = record:get("PFX_SYMBOL");
    local suffix = record:get("SFX_SYMBOL");
    local balance = record:get("Balance");
    local credit = limits[index];
    local available = credit + balance;
    record:set("Balance", prefix .. string.format("%.2f", balance) .. suffix);
    record:set("Credit", prefix .. string.format("%.2f", credit) .. suffix);
    record:set("Available",  prefix .. string.format("%.2f", available) .. suffix);
    index = index + 1;
    base_total = base_total + record:get("BaseBal");
end

function complete(result)
    result:set("Base_Total", base_total);
end

local base_total = 0;

function handle_record(record)
    local prefix = record:get("PFX_SYMBOL");
    local suffix = record:get("SFX_SYMBOL");
    local amount = record:get("TRANSAMOUNT");
    record:set("TRANSAMOUNT", prefix .. string.format("%.2f", amount) .. suffix);
    base_total = base_total + record:get("BaseAmount");
end

function complete(result)
    result:set("BaseTotal", base_total);
end
local base_total = 0;

function handle_record(record)
    base_total = base_total + record:get("BaseAmount");
end

function complete(result)
    result:set("BaseTotal", base_total);
end
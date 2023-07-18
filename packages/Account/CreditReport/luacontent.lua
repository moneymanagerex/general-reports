local base_total = 0;

function handle_record(record)
    base_total = base_total + record:get("BASEBAL");
end

function complete(result)
    result:set("BASE_TOTAL", base_total);
end

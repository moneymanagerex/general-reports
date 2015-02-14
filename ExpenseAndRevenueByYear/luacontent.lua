local cumulTotal = 0;
function handle_record(record)
    cumulTotal = cumulTotal + record:get('Total');
    record:set("cumul", cumulTotal);
end
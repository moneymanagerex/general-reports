local cumulTotal = 0;
function handle_record(record)
    cumulTotal = cumulTotal + record:get('Total');
    record:set("cumul", cumulTotal);
    periode_name= record:get('periode_name');
end

function complete(result)
    result:set("periode_name", periode_name);
end
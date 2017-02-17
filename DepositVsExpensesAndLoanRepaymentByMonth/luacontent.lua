local cumulTotal = 0;
local cumulInitialBal = nil;
function handle_record(record)
    cumulTotal = cumulTotal + record:get('Total');
    record:set("cumul", cumulTotal);
    record:set("cumulinitialbal", record:get('initialbal') + cumulTotal);
    periode_name= record:get('periode_name');
end

function complete(result)
    result:set("periode_name", periode_name);
end
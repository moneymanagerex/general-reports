local total = 0;
function handle_record(record)
    local color = record:get('COLOR');
    if (string.len(color) > 0) then
        record:set("COLOR", string.format('bgcolor=rgb(%s)', color));
    end;
    total = total + record:get('BaseAmount');
end

function complete(result)
    result:set('GRAND_TOTAL', total);
end

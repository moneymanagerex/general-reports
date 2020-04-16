
function handle_record(record)
    local balance =  record:get('BALANCE')
    local base = balance * record:get("CURRVALUE");
    local precision = tonumber(record:get("SCALE"));
    local result =string.format("%.2f", balance);
    if  precision == 1 then  result = string.format("%.0f", balance) end;
    if  precision == 10 then  result = string.format("%.1f", balance) end;

    record:set("BALANCE", result);
    record:set("BASE", string.format("%.4f", base));
end

function complete(result)
end
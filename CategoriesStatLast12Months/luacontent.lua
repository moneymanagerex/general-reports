local grandTotal = 0;
local cols = {["one"]=0, ["two"]=0, ["thr"]=0 , ["fou"]=0, ["fiv"]=0, ["six"]=0, ["sev"]=0, ["egh"]=0, ["nin"]=0, ["ten"]=0, ["ele"]=0, ["twe"]=0};

function handle_record(record)
    grandTotal = grandTotal + record:get('OVERALL');
    for key, value in pairs(cols) do
        cols[key] = cols[key] + record:get(key);
    end
end

function complete(result)
    result:set("GRAND_TOTAL", grandTotal);
    for key, value in pairs(cols) do
        result:set("TOTAL_" .. key, value);
    end
end
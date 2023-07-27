local total = 0; 
local subcategid;
function handle_record(record)
        total = record:get("TransAmount");
        subcategid = record:get("SubcategoryID");

        if (subcategid == "97") or (subcategid == "5") or (subcategid == "134") or (subcategid == "90") then
            record:set("TransAmount",-total);
        end

end
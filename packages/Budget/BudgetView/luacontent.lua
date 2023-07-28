local total = 0; 
local categid;
function handle_record(record)
        total = record:get("TransAmount");
        categid = record:get("categid");

        if (categid == "127") or (categid == "35") or (categid == "164") or (categid == "120") then
            record:set("TransAmount",-total);
        end

end
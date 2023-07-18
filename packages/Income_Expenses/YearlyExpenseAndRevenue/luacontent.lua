local name_n0 ;
local name_n1 ;
local name_n2 ;
local name_n3 ;
local name_n4 ;
local initialized=0;

local cumul_n0 = 0;
local cumul_n1 = 0;
local cumul_n2 = 0;
local cumul_n3 = 0;
local cumul_n4 = 0;

function handle_record(record)
    if initialized == 0 then
		name_n0 = record:get('name_n0');
		name_n1 = record:get('name_n1');
		name_n2 = record:get('name_n2');
		name_n3 = record:get('name_n3');
		name_n4 = record:get('name_n4');
		initialized=1;
	end
    cumul_n0 = cumul_n0 + record:get('Total');
    record:set("cumul_n0", cumul_n0);
    cumul_n1 = cumul_n1 + record:get('Total_n1');
    record:set("cumul_n1", cumul_n1);
    cumul_n2 = cumul_n2 + record:get('Total_n2');
    record:set("cumul_n2", cumul_n2);
    cumul_n3 = cumul_n3 + record:get('Total_n3');
    record:set("cumul_n3", cumul_n3);
    cumul_n4 = cumul_n4 + record:get('Total_n4');
    record:set("cumul_n4", cumul_n4);
end

function complete(result)
    result:set("name_n0", name_n0);
    result:set("name_n1", name_n1);
    result:set("name_n2", name_n2);
    result:set("name_n3", name_n3);
    result:set("name_n4", name_n4);
end
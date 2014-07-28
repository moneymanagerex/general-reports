local cols = {"2014", "2013", "2012" , "2011", "2010", "2009", "2008", "Total ('08-'14)"};
function handle_record(record)
	for i=1,8 do
   		local amount = -1*tonumber(record:get(cols[i]));
		
		if amount == 0 then
			record:set(cols[i],"");
		else
			record:set(cols[i],string.format("%.2f",amount));
		end
	end
end

local cols = {"2023","2022","2021","2020","2019", "2018", "2017", "2016", "2015", "2014", "2013", "2012" , "2011", "2010", "2009", "2008", "Total ('08-'23)"};
function handle_record(record)
	for i=1,16 do
   		local amount = -1*tonumber(record:get(cols[i]));
		
		if amount == 0 then
			record:set(cols[i],"");
		else
			record:set(cols[i],string.format("%.2f",amount));
		end
	end
end

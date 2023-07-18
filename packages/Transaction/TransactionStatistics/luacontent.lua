local totals = {0,0,0,0,0,0,0,0,0,0,0,0}
local count = {0,0,0,0,0,0,0,0,0,0,0,0}
local grand_total = 0;
local months = {"Jan", "Feb", "Mar" , "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}

function handle_record(record)
    local year_total = 0;
    local non_zero = 0;
    for i=1,12 do
        local amount = tonumber(record:get(months[i]));
        local include = 1;
        if amount == 0 then
            local y = record:get("YEAR");
            if non_zero == 0 and y == record:get("Min_Year") then
                include = 0;
            elseif y == record:get("Max_Year") then
                local remaining = 1;
                for j=i+1,12 do
                    if tonumber(record:get(months[j])) ~= 0 then
                        remaining = 0;
                        break;
                    end
                end
                if remaining == 1 then
                    include = 0;
                end
            end
        else
            non_zero = 1;
        end
        if include ~= 0 then
            year_total = year_total +  amount;
            totals[i] = totals[i] + amount;
            count[i] = count[i] +1;
            record:set(months[i], math.floor(amount));
        else
            record:set(months[i], 0);
        end
    end
    record:set("YEAR_TOTAL", year_total);
    grand_total = grand_total + year_total;
end

function complete(result)
    for i=1,12 do
        if count[i] ~= 0 then
            result:set("AVERAGE_" .. months[i], math.floor(totals[i]/count[i]));
        else
            result:set("AVERAGE_" .. months[i], "n/a");
        end
    end

    result:set("GRAND_TOTAL", grand_total);
end

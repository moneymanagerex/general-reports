local months = {"Jan", "Feb", "Mar" , "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
local labels = 'labels : [';
local data = '';
local prefix = '';
local suffix = '';
local dpchar = '';
local grpsepchar = '';
local json = [[
    datasets : [{
        fillColor : "rgba(255,255,255,0)",
        strokeColor : "rgba(0,0,0,0.5)",
        pointColor : "rgba(0,0,0,0.5)",
        pointStrokeColor : "rgba(255,255,255,0)",
        data : [%s]},{
        fillColor : "rgba(255,255,255,0)",
        strokeColor : "rgba(255,0,0,0.5)",
        pointColor : "rgba(255,0,0,0.5)",
        pointStrokeColor : "rgba(255,255,255,0)",
        data : [
    ]];
-- forecast date
local year = 0;
local month = 0;
-- Forecast line variables (Linear Regression)
local count = 0;
local count_sum = 0;
local balance_sum = 0;
local product_sum = 0;
local squared_sum = 0;
local zero_count = 0;
local last_value = 0;
local initialized =0 ;
local accountname = '';

function handle_record(record)
    if initialized == 0 then
        prefix = record:get("PFX_SYMBOL");
        suffix = record:get("SFX_SYMBOL");
        dpchar = record:get("DECIMAL_POINT");
        grpsepchar = record:get("GROUP_SEPARATOR");
        accountname = record:get("ACCOUNTNAME");
        initialized = 1;
    end
    if count ~= 0 then
        local prev_y = year;
        local prev_m = month + 1;
        if prev_m > 12 then
            prev_m = 1;
            prev_y = prev_y + 1;
        end
        year = record:get("YEAR");
        month = record:get("MONTH");
        while prev_m ~= tonumber(month) and prev_y ~= tonumber(year) do
            prev_m = prev_m + 1;
            if prev_m > 12 then
                prev_m = 1;
                prev_y = prev_y + 1;
            end
            zero_count = zero_count + 1;
            count = count + 1;
            count_sum = count_sum + count;
            squared_sum = squared_sum + (count * count);
        end
    else
        year = record:get("YEAR");
        month = record:get("MONTH");
    end
    
    local date = months[tonumber(month)] .. ' ' .. year;
    labels = labels .. '"' .. date .. '",';
    record:set("DATE", date);
    last_value = record:get("Balance");
    local balance = string.format("%.2f", last_value);
    record:set("Balance", balance);
    if tonumber(string.sub(balance,-1)) == 0  and tonumber(string.sub(balance,-2)) ~= 0 then
        data = data .. '\'' .. balance .. '\',';
    else
        data = data .. balance .. ',';
    end
-- Update forecast line calculation values
    count = count + 1;
    count_sum = count_sum + count;
    balance_sum = balance_sum + balance;
    product_sum = product_sum + (count * balance);
    squared_sum = squared_sum + (count * count);
end

function complete(result)
-- Forecast line equation
    local slope = ((count * product_sum) - (count_sum * balance_sum)) / ((count * squared_sum) - (count_sum * count_sum));
    if count < 2 then
        slope = 0;
    end
-- Forecast line values
    data = string.format(json, string.sub(data,1,-2));
    for i=1,count - zero_count do
        data = data .. ',';
    end
    for i=1,12 do
        -- Label
        month = month + 1;
        if month > 12 then
            year = year + 1;
            month = 1;
        end
        local date = months[tonumber(month)] .. ' ' .. year;
        labels = labels .. '"' .. date .. '",';
        result:set('FLABEL' .. i, date);
        -- Value
        local value = last_value + slope * i;
        local fval = string.format("%.2f", value);
        if tonumber(string.sub(fval,-1)) == 0  and tonumber(string.sub(fval,-2)) ~= 0 then
            data = data .. '\'' .. fval .. '\',';
        else
            data = data .. fval .. ',';
        end
        result:set('FVALUE' .. i, fval);
    end
    result:set('CHART_DATA', string.sub(labels,1,-2) .. "]," .. string.sub(data,1,-2) .. "]}]");
    result:set('ACCOUNTNAME', accountname);
    -- Override the base currency variables as the account may be in different currency
    result:set('PFX_SYMBOL', prefix);
    result:set('SFX_SYMBOL', suffix);
    result:set('DECIMAL_POINT', dpchar);
    result:set('GROUP_SEPARATOR', grpsepchar);
end

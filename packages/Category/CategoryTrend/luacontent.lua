local months = {"Jan", "Feb", "Mar" , "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
local labels = 'labels : [';
local data = 'datasets : [{fillColor : "rgba(0,0,0,0.5)", strokeColor : "rgba(0,0,0,0.5)", data : [';
local total = 0;
-- forecast date
local year = 0;
local month = 0;
-- Forecast line variables (Average)
local average = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
local count = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

function handle_record(record)
    year = record:get("YEAR");
    month = record:get("MONTH");
    local date = months[tonumber(month)] .. ' ' .. year;
    labels = labels .. '"' .. date .. '",';
    record:set("DATE", date);
    local amount = string.format("%.2f", tonumber(record:get("AMOUNT")));
    if tonumber(string.sub(amount,-1)) == 0  and tonumber(string.sub(amount,-2)) ~= 0 then
        data = data .. '\'' .. amount .. '\',';
    else
        data = data .. amount .. ',';
    end
    total = total + 1;
    -- Update forecast line calculation values
    count[tonumber(month)] = count[tonumber(month)] + 1;
    average[tonumber(month)] = average[tonumber(month)] + amount;
end

function complete(result)
-- Forecast line values
    data = string.sub(data,1,-2) .. ']},{fillColor:"rgba(255,0,0,0.5)",strokeColor:"rgba(255,0,0,0.5)",data:[';
    for i=1,total do
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
        local value = "0";
        if (count[tonumber(month)] > 0) then
            value = string.format("%.2f", average[tonumber(month)] / count[tonumber(month)]);
        end
        local fval = string.format("%.2f", value);
        if tonumber(string.sub(fval,-1)) == 0  and tonumber(string.sub(fval,-2)) ~= 0 then
            data = data .. '\'' .. fval .. '\',';
        else
            data = data .. fval .. ',';
        end
        result:set('FVALUE' .. i, fval);
    end
    result:set('CHART_DATA', string.sub(labels,1,-2) .. "]," .. string.sub(data,1,-2) .. "]}]");
end

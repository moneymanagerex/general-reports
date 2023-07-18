local total = 0;
local type = {}
local subtotal = {}

function is_leap_year(year)
    local ly = 0;
    if year % 4 == 0 then
        if year % 100 == 0 then
            if year % 400 == 0 then
                ly = 1;
            end
        else
            ly = 1;
        end
    end
    return ly;
end

function get_days(month, year)
    local days = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    local d = days[tonumber(month)];
    if tonumber(month) == 2 and is_leap_year(year) ~= 0 then
        d = 29;
    end
    return d;
end

function get_years(record)
    local date = record:get("STARTDATE");
    local aYear = string.sub(date,1,4);
    local aMonth = string.sub(date,6, 7);
    local aDay = string.sub(date,9);
    local cYear = os.date('%Y');
    local cMonth = os.date('%m');
    local cDay = os.date('%d');
    local nbrYears = 0;
    if aYear == cYear then
        local days = 0;
        if aMonth == cMonth then
            days = cDay - aDay;
        else
            days = get_days(aMonth, aYear) - aDay;
            if tonumber(aMonth) + 1 <= tonumber(cMonth) - 1 then
                for i = (aMonth + 1), (cMonth - 1) do
                    days = days + get_days(i, aYear);
                end
            end
            days = days + cDay;
        end
        if (tonumber(aMonth) > 2 and is_leap_year(aYear + 1) ~= 0) or (tonumber(aMonth) <= 2 and is_leap_year(aYear) ~= 0) then
            nbrYears = days / 366;
        else
            nbrYears = days / 365;
        end
    else
        nbrYears = cYear - aYear;
        if tonumber(aMonth) > tonumber(cMonth) or (aMonth == cMonth and tonumber(aDay) > tonumber(cDay)) then
            nbrYears = nbrYears - 1;
        end
        local days = get_days(aMonth, aYear) - aDay;
        for i = (aMonth + 1), 12 do
            days = days + get_days(i, aYear);
        end
        if tonumber(cMonth) > 1 then
            for i = 1, (cMonth - 1) do
                days = days + get_days(i, cYear);
            end
        end
        days = days + cDay;
        if tonumber(aMonth) < tonumber(cMonth) then
            nbrYears = nbrYears - 1;
        elseif aMonth == cMonth and tonumber(aDay) <= tonumber(cDay) then
                nbrYears = nbrYears - 1;
        end
        if (tonumber(aMonth) > 2 and is_leap_year(aYear + 1) ~= 0) or (tonumber(aMonth) <= 2 and is_leap_year(aYear) ~= 0) then
            nbrYears = nbrYears + (days / 366);
        else
            nbrYears = nbrYears + (days / 365);
        end
    end
    return nbrYears;
end

function handle_record(record)
    local index = 0;
    local cur_type = record:get("ASSETTYPE");
    for t = 1,#type do
        if cur_type == type[t] then
            index = t;
            break;
        end
    end
    if index == 0 then
        index = #type + 1;
        type[index] = cur_type;
    end

    local value = record:get("VALUE");
    local change = record:get("VALUECHANGE");
    if change ~= 'None' then
        local rate = record:get("VALUECHANGERATE") / 100;
        local years = get_years(record);
        local scale = 1;
        if change == 'Appreciates' then
            scale = math.pow(1 + rate, years);
        elseif change == 'Depreciates' then
                scale = math.pow(1 - rate, years);
        end
        value = value * scale;
    end
    total = total + value;
    if subtotal[index]  then
        subtotal[index] = subtotal[index] + value;
    else
        subtotal[index] = value;
    end
end

function complete(result)
    result:set("Current_Total", string.format("%.2f", total));
    local colors = {"#FBD4B4", "#E5B8B7", "#B6DDE8", "#B8CCE4", "#F0EDCE", "#DEE3E7", "#99FF99"};
    local rows = '';
    local data = '';
    for t = 1,#type do
        local value = string.format("%.2f", subtotal[t]);
        rows = rows .. '<tr style="background-color:' .. colors[t] .. '"><td>' .. type[t] .. '</td><td class="money text-right">' .. value .. '</td></tr>';
        data = data .. '{value: ' .. value .. ', color:"' .. colors[t] .. '", label : "' .. type[t] ..'", labelColor : "black", labelFontSize : "12", labelAlign : "center"},\n';
    end
    result:set("SubTotals", rows);
    result:set("ASSET_DATA", data);
end

local total = 0;
local forecast = {0, 0, 0, 0, 0}
local period = 5;

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
    local value = record:get("VALUE");
    local fvalue = {}
    for i = 1,period do
        fvalue[i] = value;
    end
    local change = record:get("VALUECHANGE");
    if change ~= 'None' then
        local rate = record:get("VALUECHANGERATE") / 100;
        local years = get_years(record);
        local scale = 1;
        local fscale = {}
        for i = 1,period do
            fscale[i] = scale;
        end
        if change == 'Appreciates' then
            scale = math.pow(1 + rate, years);
            for i = 1,period do
                fscale[i] = math.pow(1 + rate, years + i);
            end
        elseif change == 'Depreciates' then
                scale = math.pow(1 - rate, years);
                for i = 1,period do
                    fscale[i] = math.pow(1 - rate, years + i);
                end
        end
        value = value * scale;
        for i = 1,period do
            fvalue[i] = fvalue[i] * fscale[i];
        end
    end
    total = total + value;
    for i = 1,period do
        forecast[i] = forecast[i] + fvalue[i];
    end
end

function complete(result)
    local data = 'datasets : [{fillColor:"rgba(255,255,255,0)",strokeColor:"rgba(255,0,0,0.5)",pointColor:"rgba(255,0,0,0.5)",pointStrokeColor:"rgba(255,255,255,0)",data:[';
    local curYear = os.date('%Y');
    local curMonth = os.date('%m');
    local curDay = os.date('%d');
    local value = string.format("%.2f", total);
    if tonumber(string.sub(value,-1)) == 0  and tonumber(string.sub(value,-2)) ~= 0 then
        data = data .. '\'' .. value .. '\',';
    else
        data = data .. value .. ',';
    end
    result:set("Current_Total", value);
    for i = 1,period do
        value = string.format("%.2f", forecast[i]);
        if tonumber(string.sub(value,-1)) == 0  and tonumber(string.sub(value,-2)) ~= 0 then
            data = data .. '\'' .. value .. '\',';
        else
            data = data .. value .. ',';
        end
        result:set("Year" .. i .. "_Total", value);
        local date = os.date("*t", os.time{year=curYear+i,month=curMonth,day=curDay});
        result:set("Year" .. i .. "_Label", string.format("(%d-%02d-%02d)",date.year,date.month,date.day));
    end
    result:set('CHART_DATA', string.sub(data,1,-2) .. "]}]");
end

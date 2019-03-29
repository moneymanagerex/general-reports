local total = 0;
local prefix = '';
local suffix = '';
local dpchar = '';
local grpsepchar = '';
local forecast = {0,0,0,0,0,0};
local period = 6;
local initialized = 0;
local repeatcode = 0;
local numrepeats = 0;
local accountname = '';

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

function get_time_difference(year, month, day)
    local curYear = os.date('%Y');
    local curMonth = os.date('%m');
    local curDay = os.date('%d');
    local d = day - curDay;
    local m = 0;
    if d < 0 then
        d = d + get_days(curMonth, curYear);
        m = -1;
    end
    m = m + month - curMonth;
    local y = 0;
    if m < 0 then
        m = m + 12;
        y = -1;
    end
    y = y + year - curYear;
    return {y, m, d}
end

function get_next_date(record, previousYear, previousMonth, previousDay)
    local originalnumber = tonumber(record:get("NUMOCCURRENCES"));
    -- Auto Execute User Acknowledgment required
    if repeatcode >= 100 then
        repeatcode = repeatcode - 100;
    end
    -- Auto Execute Silent mode
    if repeatcode >= 100 then
        repeatcode = repeatcode - 100;
    end
    if repeatcode ~= -1 then
        if repeatcode < 11 or repeatcode > 14 then
            numrepeats = numrepeats - 1;
        end
    end
    local nextDate= os.time{year=previousYear,month=previousMonth,day=previousDay}
    local updatedate = 0;
    if originalnumber == -1 or tonumber(numrepeats) > 0 then
        updatedate = 1;
    end
    if updatedate ~= 0 then
        -- weekly
        if repeatcode == 1 then
            nextDate = os.time{year=previousYear,month=previousMonth,day=previousDay + 7}
        -- biweekly
        elseif repeatcode == 2 then
            nextDate = os.time{year=previousYear,month=previousMonth,day=previousDay + 14}
        -- month
        elseif repeatcode == 3 then
            nextDate = os.time{year=previousYear,month=previousMonth + 1,day=previousDay}
        -- bimonth
        elseif repeatcode == 4 then
            nextDate = os.time{year=previousYear,month=previousMonth + 2,day=previousDay}
        -- quarterly
        elseif repeatcode == 5 then
            nextDate = os.time{year=previousYear,month=previousMonth + 3,day=previousDay}
        -- half yearly
        elseif repeatcode == 6 then
            nextDate = os.time{year=previousYear,month=previousMonth + 6,day=previousDay}
        -- yearly
        elseif repeatcode == 7 then
            nextDate = os.time{year=previousYear + 1,month=previousMonth,day=previousDay}
        -- quad monthly
        elseif repeatcode == 8 then
            nextDate = os.time{year=previousYear,month=previousMonth + 4,day=previousDay}
        -- quad weekly
        elseif repeatcode == 9 then
            nextDate = os.time{year=previousYear,month=previousMonth,day=previousDay + 28}
        -- daily
        elseif repeatcode == 10 then
            nextDate = os.time{year=previousYear,month=previousMonth,day=previousDay + 1}
       -- repeat in X days or repeat in X months
        elseif repeatcode == 11 or repeatcode == 12 then
            if numrepeats ~= -1 then
                numrepeats = -1;
            end
       -- every X days
        elseif repeatcode == 13 then
            nextDate = os.time{year=previousYear,month=previousMonth,day=previousDay + numrepeats}
        -- every X months
        elseif repeatcode == 14 then
            nextDate = os.time{year=previousYear,month=previousMonth + numrepeats,day=previousDay}
        -- month last day or monthly last business day
        elseif repeatcode == 15 or repeatcode == 16 then
            local m = previousMonth + 1;
            local y = previousYear;
            if m > 12 then
                m = 1;
                y = y + 1;
            end
            nextDate = os.time{year=y,month=m,day=get_days(m, y)}
            -- monthly last business day
            if repeatcode == 16 then
                local n = os.date("*t", nextDate);
                -- Sunday
                if n.wday == 0 then
                    nextDate = os.time{year=n.year,month=n.month,day=n.day - 2}
                -- Saturday
                elseif n.wday == 7 then
                    nextDate = os.time{year=n.year,month=n.month,day=n.day - 1}
                end
            end
        end
    end
    local next = os.date("*t", nextDate);
    return {next.year, next.month, next.day}
end

function handle_record(record)
    if initialized == 0 then
        total = record:get("Balance");
        prefix = record:get("PFX_SYMBOL");
        suffix = record:get("SFX_SYMBOL");
        dpchar = record:get("DECIMAL_POINT");
        grpsepchar = record:get("GROUP_SEPARATOR");
        accountname = record:get("ACCOUNTNAME");
        for i=1,period do
            forecast[i] = total;
        end
        initialized = 1;
    end
    repeatcode = tonumber(record:get("REPEATS"));
    numrepeats = record:get("NUMOCCURRENCES");
    local amount = record:get("TRANSAMOUNT");
    local nextDate = record:get("NEXTOCCURRENCEDATE");
    local nextYear = tonumber(string.sub(nextDate,1,4));
    local nextMonth = tonumber(string.sub(nextDate,6, 7));
    local nextDay = tonumber(string.sub(nextDate,9));
    local timediff = get_time_difference(nextYear, nextMonth, nextDay);
    while (timediff[2] < period and timediff[1] == 0) or  timediff[1] < 0 do
        local m = timediff[2] + 1;
        if timediff[1] < 0 then
            m = 1;
        end
        for i=m,period do
            forecast[i] = forecast[i] + amount;
        end
        local next = get_next_date(record, nextYear, nextMonth, nextDay);
        if next[1] == nextYear and next[2] == nextMonth and next[3] == nextDay then
            break;
        end
        nextYear = next[1];
        nextMonth = next[2];
        nextDay = next[3];
        timediff = get_time_difference(nextYear, nextMonth, nextDay);
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
    for i=1,period do
        value = string.format("%.2f", forecast[i]);
        if tonumber(string.sub(value,-1)) == 0  and tonumber(string.sub(value,-2)) ~= 0 then
            data = data .. '\'' .. value .. '\',';
        else
            data = data .. value .. ',';
        end
        result:set("Month" .. i .. "_Total", value);
        local date = os.date("*t", os.time{year=curYear,month=curMonth+i,day=curDay});
        result:set("Month" .. i .. "_Label", string.format("(%d-%02d-%02d)",date.year,date.month,date.day));
    end
    result:set('CHART_DATA', string.sub(data,1,-2) .. "]}]");
    -- Override the base currency variables as the account may be in different currency
    result:set('PFX_SYMBOL', prefix);
    result:set('SFX_SYMBOL', suffix);
    result:set('DECIMAL_POINT', dpchar);
    result:set('GROUP_SEPARATOR', grpsepchar);
    result:set('ACCOUNTNAME', accountname);
end

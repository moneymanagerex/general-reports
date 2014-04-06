local months = {"Jan", "Feb", "Mar" , "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
local colors = {"#FF6666", "#FFB266", "#FFFF66", "#B2FF66", "#66FF66", "#66FFB2", "#66FFFF", "#66B2FF", "#6666FF", "#B266FF", "#FF66FF", "#FF66B2"};
local data = '';
local json = [[
    {fillColor : "rgba(255,255,255,0)",
    strokeColor : "%s",
    pointColor : "%s",
    pointStrokeColor : "rgba(255,255,255,0)",
    data : [
    ]];

function handle_record(record)
    local color = colors[1 + (tonumber(record:get('YEAR')) % #colors)];
    record:set('COLOR', color);
    local datalimit = 12;
    if record:get("YEAR") >= os.date('%Y') then
        for i=12,os.date('%m'),-1 do
            if tonumber(record:get(months[i])) > 0 then
                datalimit = i;
                break;
            end
        end
    end
    data = data .. string.format(json, color, color);
    for i=1,12 do
        if i <= datalimit then
            local amount = string.format("%.2f", tonumber(record:get(months[i])));
            if tonumber(string.sub(amount,-1)) == 0  and tonumber(string.sub(amount,-2)) ~= 0 then
                data = data .. '\'' .. amount .. '\'';
            else
                data = data .. amount;
            end
            if i ~= datalimit then
                data = data .. ',';
            end
        end
    end
    data = data .. ']},';
end

function complete(result)
    result:set('TREND_DATA', string.sub(data,1,-1));
end

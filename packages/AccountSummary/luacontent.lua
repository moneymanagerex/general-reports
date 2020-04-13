local total = 0;
local data = '';
local count = 0;
local colors = {"#FF6666", "#FFB266", "#FFFF66", "#B2FF66", "#66FF66", "#66FFB2", "#66FFFF", "#66B2FF", "#6666FF", "#B266FF", "#FF66FF", "#FF66B2"};

function handle_record(record)
    local base = record:get('BALANCE') * record:get("CURRVALUE");
    record:set("BASE", base);
    total = total + base;
    local color = colors[1 + (count % #colors)];
    data = data .. '{value:' .. string.format("%.2f", base) .. ',color:"' .. color .. '"},';
    record:set('COLOR', color);
    count = count + 1;
end

function complete(result)
    result:set("Total", total);
    result:set('CHART_DATA', string.sub(data,1,-2));
end
local total = 0;
local count = 0;
local colors = {"#FF6666", "#FFB266", "#FFFF66", "#B2FF66", "#66FF66", "#66FFB2", "#66FFFF", "#66B2FF", "#6666FF", "#B266FF", "#FF66FF", "#FF66B2"};

function handle_record(record)
    local color = colors[1 + (count % #colors)];
    count = count + 1;
    record:set('COLOR', color);
    total = total + record:get('VALUE');
    local value = string.format("%.2f", record:get('VALUE'));
end

function complete(result)
    result:set('STOCK_TOTAL', total);
end

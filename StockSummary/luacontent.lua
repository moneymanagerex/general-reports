local total = 0;
local count = 1;
local colors = {"#FF6666", "#FFB266", "#FFFF66", "#B2FF66", "#66FF66", "#66FFB2", "#66FFFF", "#66B2FF", "#6666FF", "#B266FF", "#FF66FF", "#FF66B2"};
local data = '';
local json = [[
    {value: %s,
    color: "%s",
    label: "%s",
    labelColor: "black",
    labelFontSize: "12",
    labelAlign: "center"},
    ]];

function handle_record(record)
    local color = colors[count % #colors];
    count = count + 1;
    record:set('COLOR', color);
    total = total + record:get('VALUE');
    local value = string.format("%.2f", record:get('VALUE'));
    data = data .. string.format(json, value, color, record:get('SYMBOL'));
end

function complete(result)
    result:set('STOCK_TOTAL', total);
    result:set('STOCK_DATA', data);
end

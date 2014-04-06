local count = 0;
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
    local color = colors[1 + (count % #colors)];
    count = count + 1;
    record:set('COLOR', color);
    local value = string.format("%.2f", record:get('Quantity'));
    data = data .. string.format(json, value, color, record:get('CURRENCY_SYMBOL'));
end

function complete(result)
    result:set('CURRENCY_DATA', data);
end

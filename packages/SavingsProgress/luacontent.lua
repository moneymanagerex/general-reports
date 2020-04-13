local count = 0;
local colors = {"#C00000", "#FF0000", "#FFC000", "#FFFF00", "#FFFF99", "#92D050", "#00B050", "#00B0F0", "#0070C0", "#002060",  "#7030A0", "#EF03C2", "#EEECE1", "#FCD5B4", "#E46D0A"};

function handle_record(record)
    local color = colors[1 + (count % #colors)];
    count = count + 1;
    record:set('COLOR', color);
end

function complete(result)
end

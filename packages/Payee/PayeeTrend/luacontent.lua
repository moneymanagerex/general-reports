local months = {"Jan", "Feb", "Mar" , "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
local colors = {"#FF6666", "#FFB266", "#FFFF66", "#B2FF66", "#66FF66", "#66FFB2", "#66FFFF", "#66B2FF", "#6666FF", "#B266FF", "#FF66FF", "#FF66B2"};
payeename = ''

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
    payeename = record:get('PAYEENAME');
end

function complete(result)
     result:set('PAYEENAME', payeename);
end

local gdata=''
local gdataincome=''
local gdataexpense=''
local gdatadiff=''
local glabels=''
local yeartype=''
local initialized=0

local titles = {'Income','Expenses','Difference'} -- don't change the order
local colors = {"#66FFB2","#FF6666","#66B2FF"} -- alter colours if you desire

function handle_record(record)
    if (initialized==0) then
        yeartype=record:get('YEARTYPE')
        initialized=1
    end
    local diff=record:get('INCOME') - record:get('EXPENSE')
    record:set('DIFFERENCE', diff)
 -- Labels
    if (glabels:len() > 0) then
        glabels=glabels .. ','
        gdataincome=gdataincome .. ','
        gdataexpense=gdataexpense .. ','
        gdatadiff=gdatadiff .. ','
    end
    glabels=glabels .. '"' .. tostring(record:get('YEAR')) .. '"'
    gdataincome=gdataincome .. tostring(record:get('INCOME'))
    gdataexpense=gdataexpense .. tostring(record:get('EXPENSE'))
    gdatadiff=gdatadiff .. tostring(diff)
end

function complete(result)
    local gformatting='{fillColor:"<colour>",strokeColor:"<colour>", data:['
    local gtitles='],title:"'
    result:set('GLABELS', glabels)
    gdata=gformatting:gsub('<colour>',colors[1]) .. tostring(gdataincome) .. gtitles .. titles[1] .. '"}'
    gdata=gdata .. ',' .. gformatting:gsub('<colour>',colors[2]) .. tostring(gdataexpense) .. gtitles .. titles[2] .. '"}'
    gdata=gdata .. ',' .. gformatting:gsub('<colour>',colors[3]) .. tostring(gdatadiff) .. gtitles .. titles[3] .. '"}'
    result:set('CHART_DATA', gdata)

    if (yeartype=='FIN_YEAR') then
        result:set('YEAR_TYPE', 'Finanical Year')
    else
        result:set('YEAR_TYPE', 'Calendar Year')
    end
end
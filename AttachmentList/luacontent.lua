function get_base_path (BasePath,FilePath)
    if BasePath == "DOCSDIR" then
       BasePath = "#";
    elseif BasePath == "MMEXDIR" then
       BasePath = "#";
    elseif BasePath == "DBDIR" then
       BasePath = "#";
    else
       BasePath = "file:///" .. BasePath .. FilePath;
   end
    return BasePath;
end

function handle_record(record)
    record:set("BasepathLUA", get_base_path(record:get("BasePath"),record:get("FilePath")));
end
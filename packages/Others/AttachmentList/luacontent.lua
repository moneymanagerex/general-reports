function handle_record(record)
    record:set("BasepathLUA", record:GetDir(record:get("BasePath")) .. record:get("FilePath"));
end
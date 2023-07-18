function handle_record(record)
    record:set("TRX_LINK", string.format('<a href="trx:%s" target="_blank">%s</a>', record:get('id'),  record:get('id')));
    record:set("TRX_LINK_GO", string.format('<a href="trxid:%s" target="_blank">%s</a>', record:get('id'),  record:get('account')));
end

function complete(result)

end

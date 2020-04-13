
function handle_record(record)
    record:set("TRX_LINK", string.format('<a href="trx:%s">%s</a>', record:get('TRANSID'),  record:get('TRANSID')));
    record:set("TRX_LINK_GO", string.format('<a href="trxid:%s">%s</a>', record:get('TRANSID'),  record:get('Account')));
end

function complete(result)

end
local base_total = 0;
local credit_total = 0;
local avail_total = 0;

function handle_record(record)
    local prefix = record:get("PFX_SYMBOL");
    local suffix = record:get("SFX_SYMBOL");
    local balance = record:get("Balance");
    local credit = record:get("CreditLimit");
    local available = record:get("AvailableCredit");
    local InterestRate = record:get("InterestRate");
    record:set("Balance", prefix .. string.format("%.2f", balance) .. suffix);
    record:set("Credit", prefix .. string.format("%.2f", credit) .. suffix);
    record:set("Available",  prefix .. string.format("%.2f", available) .. suffix);
    record:set("InterestRate", prefix .. string.format("%.2f", InterestRate) .. suffix);
    base_total = base_total + record:get("BaseBal");
    credit_total = credit_total + record:get("CreditLimit");
    avail_total = avail_total + record:get("AvailableCredit");
end

function complete(result)
    result:set("Base_Total", base_total);
    result:set("Credit_Total", credit_total);
    result:set("Avail_Total", avail_total);
end
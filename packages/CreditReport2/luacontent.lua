local base_bal_total = 0;
local base_credit_total = 0;
local base_avail_total = 0;
local exchg_rate = 1;

function handle_record(record)
    exchg_rate = record:get("CURRVALUE");
    base_bal_total = base_bal_total + (record:get("Balance") * exchg_rate);
    base_credit_total = base_credit_total + (record:get("CreditLimit")  * exchg_rate);
    base_avail_total = base_avail_total + (record:get("AvailableCredit") * exchg_rate);
end

function complete(result)
    result:set("Base_Bal_Total", base_bal_total);
    result:set("Base_Credit_Total", base_credit_total);
    result:set("Base_Avail_Total", base_avail_total);
end
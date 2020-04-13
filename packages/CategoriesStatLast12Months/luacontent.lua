local grandTotal = 0;
local TotalWithdraw = 0;
local TotalDeposit = 0;
local cols = {["one"]=0, ["two"]=0, ["thr"]=0 , ["fou"]=0, ["fiv"]=0, ["six"]=0, ["sev"]=0, ["egh"]=0, ["nin"]=0, ["ten"]=0, ["ele"]=0, ["twe"]=0};
local colsWithdraw = {["one"]=0, ["two"]=0, ["thr"]=0 , ["fou"]=0, ["fiv"]=0, ["six"]=0, ["sev"]=0, ["egh"]=0, ["nin"]=0, ["ten"]=0, ["ele"]=0, ["twe"]=0};
local colsDeposit = {["one"]=0, ["two"]=0, ["thr"]=0 , ["fou"]=0, ["fiv"]=0, ["six"]=0, ["sev"]=0, ["egh"]=0, ["nin"]=0, ["ten"]=0, ["ele"]=0, ["twe"]=0};

function handle_record(record)
    grandTotal = grandTotal + record:get('OVERALL');
    for key, value in pairs(cols) do
        withdrawAmount=record:get("WITH_" .. key);
        depositAmount=record:get("DEP_" .. key);
        cols[key] = cols[key] + record:get(key);
        colsWithdraw[key] = colsWithdraw[key] + withdrawAmount;
        colsDeposit[key] = colsDeposit[key] + depositAmount;
        TotalWithdraw = TotalWithdraw + withdrawAmount;
        TotalDeposit = TotalDeposit + depositAmount;
     end
end

function complete(result)
    result:set("GRAND_TOTAL", grandTotal);
    result:set("TOTAL_WITHDRAW", TotalWithdraw);
    result:set("TOTAL_DEPOSIT", TotalDeposit);
    for key, value in pairs(cols) do
        result:set("TOTAL_" .. key, value);
    end
    for key, value in pairs(colsWithdraw) do
        result:set("WITH_" .. key, value);
    end
    for key, value in pairs(colsDeposit) do
        result:set("DEPOSIT_" .. key, value);
    end
end
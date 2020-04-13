local dashboardChartsJsOutput = '';
---
-- The color definition of withdrawal colors. The "start" marks the left including value of
-- the range, the "end" marks the right excluding value.
-- 
-- The first 100% of withdrawal colors are green, as it's better be under budget.
-- 
local withdrawalColors = {};
withdrawalColors[1] = { ["start"] = -1, ["end"] = 25, ["color"] = "#009900"};
withdrawalColors[2] = { ["start"] = 25, ["end"] = 50, ["color"] = "#00CC00"};
withdrawalColors[3] = { ["start"] = 50, ["end"] = 75, ["color"] = "#00EE00"};
withdrawalColors[4] = { ["start"] = 75, ["end"] = 100, ["color"] = "#44FF00"};
withdrawalColors[5] = { ["start"] = 100, ["end"] = 105, ["color"] = "#88FF00"};
withdrawalColors[6] = { ["start"] = 105, ["end"] = 110, ["color"] = "#BBFF00"};
withdrawalColors[7] = { ["start"] = 110, ["end"] = 115, ["color"] = "#FFDD00"};
withdrawalColors[8] = { ["start"] = 115, ["end"] = 120, ["color"] = "#FFBB00"};
withdrawalColors[9] = { ["start"] = 120, ["end"] = 130, ["color"] = "#FF8800"};
withdrawalColors[10] = { ["start"] = 130, ["end"] = 150, ["color"] = "#FF4400"};
withdrawalColors[11] = { ["start"] = 150, ["end"] = 170, ["color"] = "#EE0000"};
withdrawalColors[12] = { ["start"] = 170, ["end"] = 190, ["color"] = "#CC0000"};
withdrawalColors[13] = { ["start"] = 190, ["end"] = 9999, ["color"] = "#990000"};

---
-- The color definition of desposit colors. 
-- 
-- The first 90% of deposit colors are red, as it's better to be over budget.
-- 
local depositColors = {};
depositColors[1] = { ["start"] = -1, ["end"] = 10, ["color"] = "#990000"};
depositColors[2] = { ["start"] = 10, ["end"] = 30, ["color"] = "#CC0000"};
depositColors[3] = { ["start"] = 30, ["end"] = 50, ["color"] = "#EE0000"};
depositColors[4] = { ["start"] = 50, ["end"] = 70, ["color"] = "#FF4400"};
depositColors[5] = { ["start"] = 70, ["end"] = 80, ["color"] = "#FF8800"};
depositColors[6] = { ["start"] = 80, ["end"] = 85, ["color"] = "#FFBB00"};
depositColors[7] = { ["start"] = 85, ["end"] = 90, ["color"] = "#FFDD00"};
depositColors[8] = { ["start"] = 90, ["end"] = 95, ["color"] = "#BBFF00"};
depositColors[9] = { ["start"] = 95, ["end"] = 100, ["color"] = "#88FF00"};
depositColors[10] = { ["start"] = 100, ["end"] = 125, ["color"] = "#44FF00"};
depositColors[11] = { ["start"] = 125, ["end"] = 150, ["color"] = "#00EE00"};
depositColors[12] = { ["start"] = 150, ["end"] = 175, ["color"] = "#00CC00"};
depositColors[13] = { ["start"] = 175, ["end"] = 9999, ["color"] = "#009900"};

---
-- The sum of the expenses budget over all category budgets
-- 
local budgetExpenseSum = 0;

---
-- The sum of the income budget over all category budgets
-- 
local budgetIncomeSum = 0;

---
-- The sum of all actual expenses over all categories
-- 
local actualExpenseSum = 0;

---
-- The sum of all actual incomes over all categories
-- 
local actualIncomeSum = 0;

---
-- symbols of base currency
-- 
local baseCurrencyPrefixSymbol = nil;
local baseCurrencySuffixSymbol = nil;

---
-- Set the currency symbols by the base currency field of the record
-- 
function setBaseCurrencySymbol(record) 
    if (baseCurrencyPrefixSymbol == nil and baseCurrencySuffixSymbol == nil) then
        baseCurrencyPrefixSymbol = record:get("BaseCurrencyPrefixSymbol");
        baseCurrencySuffixSymbol = record:get("BaseCurrencySuffixSymbol");
    end
end

---
-- Create the javascript chart code for the given category record, which contains the Code of the
-- transaction (Withdrawal or Deposit), the c ategory id, the category name, the budget amount
-- and the actual amount. The rate determines the quotient of actual amount and budget amount.
-- 
-- @param #table record a record of the database query
-- 
function createChartCodeForCategoryBudget(record) 
    local template = [==[
        var c%d = $('<div style="width: 125px; float: left; margin: 0 auto;" />').appendTo('#chartContainer%s');
        c%d.dxLinearGauge($.extend(true, {}, linearGaugeOptions, {
            title: { text: '%s', },
            scale: {
                startValue: 0, 
                endValue: %d, 
                majorTick: { customTickValues: [%d], },
            },
            value: %f,
            valueIndicator: { color: '%s', },
        }));
    ]==];
    local colorDefinition = withdrawalColors;
    if record:get("TransCode") == "Deposit" then
        colorDefinition = depositColors;
    end
    
    if tonumber(record:get("BudgetAmount")) < 0.1 then
        record:set("BudgetAmount",  record:get("ActualAmount") );
    end
    
    local color = determineRateColor(record:get("Rate"), colorDefinition);
    local js = string.format(template
        , record:get("CategoryId")
        , record:get("TransCode")
        , record:get("CategoryId")
        , record:get("Category")
        , 2 * record:get("BudgetAmount")
        , record:get("BudgetAmount"), record:get("ActualAmount")
        , color);
    
    return js;
end

---
-- Create the javascript chart code for comparison of two values. The given title is used as chart
-- title, the type specifies if its a expense or income chart (regarding color definition).
-- 
-- @param #string title the title of the chart
-- @param #float compareValue the comparison value which is displayed as value of the gauge
-- @param #float referenceValue the reference value which is displayed as subvalue at "12 o'clock"
-- @param #string type type of color definition expenses or income
-- 
function createChartCodeForComparison(title, compareValue, referenceValue, type)
    local normTitle = string.gsub(title, "%A", "");
    local template = [==[
        var d%s = $('<div style="width: 380px; float: left; margin: 0 auto;" />').appendTo('#chartContainerOverall');
        d%s.dxCircularGauge($.extend(true, {}, circularGaugeOptions, {
                title: { text: '%s', },
                scale: {
                    startValue: 0, 
                    endValue: %d, 
                },
                rangeContainer: {
                    ranges: [
                        %s
                    ],
                },
                value: %f,
                subvalues: [ %f ],
            }));
    ]==];
    
    local colorDefinition = withdrawalColors;
    if type == "Income" then
        colorDefinition = depositColors;
    end
    
    local jsRangeContainerTemplate = determineRangeColorsAsJs(referenceValue, colorDefinition);
    
    local js = string.format(template
        , normTitle
        , normTitle
        , title
        , 2 * referenceValue
        , jsRangeContainerTemplate
        , compareValue
        , referenceValue
    );
    
    return js;
end

---
-- Determine the colored ranges of the chart by the color definition. The maxValue is used to
-- calculate real values by the percentage values of the color definition.
-- 
-- The ranges will be returned as javascript code, which will be inserted into the chart options.
-- 
-- @param #float maxValue the maximum value of the ranges
-- @param #table colorDefinition defines the ranges and their colors
-- 
function determineRangeColorsAsJs(maxValue, colorDefinition)
    local js = "";
    local rangeTemplate = [==[
        { startValue: %d, endValue: %d, color: '%s' },
    ]==];
    for i = 1, #colorDefinition do
        js = js .. string.format(rangeTemplate
            , maxValue * (colorDefinition[i]["start"] / 100)
            , maxValue * (colorDefinition[i]["end"] / 100)
            , colorDefinition[i]["color"]
        );
    end
    
    return js;
end

---
-- Determine the color for the given rateString from the specified colorDefinition. If the range
-- has been found for the given rate, the according color will be returned.
-- 
-- @param #string rateString the rate which should be colored
-- @param #table colorDefinition defines the ranges and their colors
-- 
function determineRateColor(rateString, colorDefinition)
    local rate = tonumber(rateString); 
    for i = 1, #colorDefinition do
        if colorDefinition[i]["start"] < rate and rate <= colorDefinition[i]["end"] then
            color = colorDefinition[i]["color"];
            break;
        end
    end
        
    return color;
end

---
-- Update the sum values by the actual and budget amount of the record, dependent on the transaction
-- code
-- 
-- @param #table record the record of the database query
-- 
function updateAmountSumsBy(record) 
    if record:get("TransCode") == "Withdrawal" then
        budgetExpenseSum = budgetExpenseSum + record:get("BudgetAmount");
        actualExpenseSum = actualExpenseSum + record:get("ActualAmount");
    elseif record:get("TransCode") == "Deposit" then
        budgetIncomeSum = budgetIncomeSum + record:get("BudgetAmount");
        actualIncomeSum = actualIncomeSum + record:get("ActualAmount");
    end
end

---
-- Handle each record which will be returned by the database query
-- 
-- @param #table record the record of the database query
-- 
function handle_record(record) 
    local jsOutputPerRecord = createChartCodeForCategoryBudget(record);
    
    setBaseCurrencySymbol(record);
    
    updateAmountSumsBy(record);
    
    dashboardChartsJsOutput = dashboardChartsJsOutput .. jsOutputPerRecord;
end

---
-- Function will be called after all records have been handled. The chart code for the sum values
-- will be created and put into a result table, which can be inserted within the template
-- 
-- @param #table result placeholder for javascript code to be inserted into the template
-- 
function complete(result)
    if actualIncomeSum == 0 then
        actualIncomeSum = actualExpenseSum / 2;
    end
    local jsExpenseIncome = createChartCodeForComparison("Expenses vs Income"
        , actualExpenseSum, actualIncomeSum, "Expense");
    local jsExpenseBudget = createChartCodeForComparison("Expense vs Budget"
        , actualExpenseSum, budgetExpenseSum, "Expense");
    local jsIncomeBudget = createChartCodeForComparison("Income vs Budget"
        , actualIncomeSum, budgetIncomeSum, "Income");
    
    result:set("EXPENSE_INCOME_DATA", jsExpenseIncome);
    result:set("EXPENSE_BUDGET_DATA", jsExpenseBudget);
    result:set("INCOME_BUDGET_DATA", jsIncomeBudget);
    result:set("DASHBOARD_DATA", dashboardChartsJsOutput);
    
    local date = os.date("*t", os.time{year=os.date('%Y'), month=os.date('%m'), day=1} - (24 * 60 * 60));
    result:set("REPORT_DATE", string.format("%d-%02d-%02d",date.year,date.month,date.day));
    
    result:set("BASE_CURRENCY_PREFIX_SYMBOL", baseCurrencyPrefixSymbol);
    result:set("BASE_CURRENCY_SUFFIX_SYMBOL", baseCurrencySuffixSymbol);
end
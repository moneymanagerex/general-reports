local dashboardChartsJsOutput = '';

---
-- The color definition of expense colors. The "start" marks the left including value of
-- the range, the "end" marks the right excluding value.
-- 
-- The first 100% of expense colors are green, as it's better be under budget.
-- 
local expenseColors = {};
expenseColors[1] = { ["start"] = -1, ["end"] = 25, ["color"] = "#009900"};
expenseColors[2] = { ["start"] = 25, ["end"] = 50, ["color"] = "#00CC00"};
expenseColors[3] = { ["start"] = 50, ["end"] = 75, ["color"] = "#00EE00"};
expenseColors[4] = { ["start"] = 75, ["end"] = 100, ["color"] = "#44FF00"};
expenseColors[5] = { ["start"] = 100, ["end"] = 105, ["color"] = "#88FF00"};
expenseColors[6] = { ["start"] = 105, ["end"] = 110, ["color"] = "#BBFF00"};
expenseColors[7] = { ["start"] = 110, ["end"] = 115, ["color"] = "#FFDD00"};
expenseColors[8] = { ["start"] = 115, ["end"] = 120, ["color"] = "#FFBB00"};
expenseColors[9] = { ["start"] = 120, ["end"] = 130, ["color"] = "#FF8800"};
expenseColors[10] = { ["start"] = 130, ["end"] = 150, ["color"] = "#FF4400"};
expenseColors[11] = { ["start"] = 150, ["end"] = 170, ["color"] = "#EE0000"};
expenseColors[12] = { ["start"] = 170, ["end"] = 190, ["color"] = "#CC0000"};
expenseColors[13] = { ["start"] = 190, ["end"] = 9999, ["color"] = "#990000"};

---
-- The color definition of income colors. 
-- 
-- The first 90% of income colors are red, as it's better to be over budget.
-- 
local incomeColors = {};
incomeColors[1] = { ["start"] = -1, ["end"] = 10, ["color"] = "#990000"};
incomeColors[2] = { ["start"] = 10, ["end"] = 30, ["color"] = "#CC0000"};
incomeColors[3] = { ["start"] = 30, ["end"] = 50, ["color"] = "#EE0000"};
incomeColors[4] = { ["start"] = 50, ["end"] = 70, ["color"] = "#FF4400"};
incomeColors[5] = { ["start"] = 70, ["end"] = 80, ["color"] = "#FF8800"};
incomeColors[6] = { ["start"] = 80, ["end"] = 85, ["color"] = "#FFBB00"};
incomeColors[7] = { ["start"] = 85, ["end"] = 90, ["color"] = "#FFDD00"};
incomeColors[8] = { ["start"] = 90, ["end"] = 95, ["color"] = "#BBFF00"};
incomeColors[9] = { ["start"] = 95, ["end"] = 100, ["color"] = "#88FF00"};
incomeColors[10] = { ["start"] = 100, ["end"] = 125, ["color"] = "#44FF00"};
incomeColors[11] = { ["start"] = 125, ["end"] = 150, ["color"] = "#00EE00"};
incomeColors[12] = { ["start"] = 150, ["end"] = 175, ["color"] = "#00CC00"};
incomeColors[13] = { ["start"] = 175, ["end"] = 9999, ["color"] = "#009900"};

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
-- Accounts which are contained in report
-- 
local selectedAccounts = "all";

---
-- available types map withdrawal to expenses and deposit to incomes
-- 
local availableTypes = {
  ["Deposit"] = { ["label"] = "Incomes", ["name"] = "income" },
  ["Withdrawal"] = { ["label"] = "Expenses", ["name"] = "expense" }
};

--
---
-- current type: income or expense
-- 
local currentType = "";

---
-- Handle each record which will be returned by the database query
-- 
-- @param #table record the record of the database query
-- 
function handle_record(record)  
    local origLocale = os.setlocale("", "numeric");
    os.setlocale("C", "numeric");

    do_handle_record(record);

    os.setlocale(origLocale, "numeric");
end

function do_handle_record(record)
    if (record:get("CategoryId") == nil or record:get("CategoryId") == "") then
        do_handle_accounts(record);
    else 
        do_handle_category(record);
    end
end

function do_handle_accounts(record)
    selectedAccounts = record:get("Category");
end

function do_handle_category(record)
    setBaseCurrencySymbol(record);
    
    if isNewType(record:get("TransCode")) then
        markRecordAsNewType(record);
    end
    
    dashboardChartsJsOutput = dashboardChartsJsOutput .. createChartCodeForCategoryBudget(record);
    
    updateAmountSumsBy(record);
end


---
-- Set the currency symbols by the base currency field of the record
-- 
function setBaseCurrencySymbol(record) 
    if (baseCurrencyPrefixSymbol == nil) then
        baseCurrencyPrefixSymbol = record:get("BaseCurrencyPrefixSymbol");
    end
    
    if (baseCurrencySuffixSymbol == nil) then
        baseCurrencySuffixSymbol = record:get("BaseCurrencySuffixSymbol");
    end
end

---
-- Checks, if the transCode is new type during records loop
-- 
function isNewType(transCode) 
    return availableTypes[transCode]["label"] ~= currentType
end

function markRecordAsNewType(record)
    currentType = availableTypes[record:get("TransCode")]["label"];
    
    record:set("SwitchType", 1);
    record:set("Type", currentType);
end

---
-- Create the javascript chart code for the given category record, which contains the Code of the
-- transaction (Withdrawal or Deposit), the c ategory id, the category name, the budget amount
-- and the actual amount. The rate determines the quotient of actual amount and budget amount.
-- 
-- @param #table record a record of the database query
-- 
function createChartCodeForCategoryBudget(record) 
    local type = availableTypes[record:get("TransCode")]["name"];
    local template = [==[
    const category%sRateOptions = {
        chart: {
            id: 'cat-%s',
            group: '%s',
            height: 20,
            width: 160,
            type: 'bar',
            stacked: true,
            sparkline: {
                enabled: true,
            },
            animations: {
                enabled: false,
            }
        },
        series: [{
            name: '%s',
            data: [ %f ],
        }, {
            name: 'Rest',
            data: [ %f ],
        }],
        xaxis: {
            min: 0,
            max: 100,
        },
        plotOptions: {
            bar: {
                horizontal: true,
            }
        },
        colors: ['%s', '%s'],
        tooltip: {
            enabled: false
        },
        fill: {
            opacity: [ 1, %s ],
        },
    };
    new ApexCharts(document.querySelector("#category-%s-rate"), category%sRateOptions).render();
    ]==];
    local colorDefinition = loadColorDefinition(type);
    
    local opacity = 1;
    local barValue = tonumber(record:get("Rate"));
    local backgroundColor = '#EEEEEE'
    if barValue > 100 then
      barValue = barValue - 100;
      backgroundColor = determineColor(colorDefinition, 100);
      opacity = 0.7;
    end
    local backgroundValue = 100 - barValue;
    if backgroundValue < 0 then
      backgroundValue = 0;
    end
    
    local color = determineColor(colorDefinition, tonumber(record:get("Rate"))); -- real value
    local js = string.format(template
        , record:get("CategoryId")
        , record:get("CategoryId")
        , type
        , record:get("Category")
        , barValue
        , backgroundValue
        , color
        , backgroundColor
        , opacity
        , record:get("CategoryId")
        , record:get("CategoryId"));
    
    return js;
end

function loadColorDefinition(type) 
    local colorDefinition = expenseColors;
    if type == "income" then
        colorDefinition = incomeColors;
    end
    
    return colorDefinition;
end

---
-- Determine the color for the given rate
-- 
-- @param #table colorDefinition defines the ranges and their colors
-- @param #float rate 
-- 
function determineColor(colorDefinition, rate)
    local color = "";

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
        budgetExpenseSum = budgetExpenseSum + tonumber(record:get("BudgetAmount"));
        actualExpenseSum = actualExpenseSum + tonumber(record:get("ActualAmount"));
    elseif record:get("TransCode") == "Deposit" then
        budgetIncomeSum = budgetIncomeSum + tonumber(record:get("BudgetAmount"));
        actualIncomeSum = actualIncomeSum + tonumber(record:get("ActualAmount"));
    end
end

---
-- Function will be called after all records have been handled. The chart code for the sum values
-- will be created and put into a result table, which can be inserted within the template
-- 
-- @param #table result placeholder for javascript code to be inserted into the template
-- 
function complete(result)
    local origLocale = os.setlocale("", "numeric");
    os.setlocale("C", "numeric");

    do_complete(result);

    os.setlocale(origLocale, "numeric");
end

function do_complete(result)
    local date = os.date("*t", os.time{year=os.date('%Y'), month=os.date('%m'), day=os.date('%d')});
    result:set("CREATED_AT", os.date("%c"));
    result:set("SELECTED_ACCOUNTS", selectedAccounts);
    
    result:set("MONEY_STYLE", generateCurrencyCss());
    
    local incomeRate = tonumber(string.format("%.2f", (actualIncomeSum / budgetIncomeSum) * 100));
    local jsIncomeBudget = createChartForComparison("income", "Income % of Budget", incomeRate);
    result:set("INCOME_BUDGET_DATA", jsIncomeBudget);
    result:set("BUDGET_INCOME_SUM", budgetIncomeSum);
    result:set("ACTUAL_INCOME_SUM", actualIncomeSum);
    result:set("INCOME_DIFF_SUM", actualIncomeSum - budgetIncomeSum); -- negative if actual less than budget
    
    local expenseRate = tonumber(string.format("%.2f", (actualExpenseSum / budgetExpenseSum) * 100));
    local jsExpenseBudget = createChartForComparison("expense", "Expense % of Budget", expenseRate);
    local jsExpenseBudgetSparkline = createSparklineChartForComparison("expense", expenseRate);
    result:set("EXPENSE_BUDGET_DATA", jsExpenseBudget);
    result:set("EXPENSE_BUDGET_SPARKLINE_DATA", jsExpenseBudgetSparkline);
    result:set("BUDGET_EXPENSE_SUM", budgetExpenseSum);
    result:set("ACTUAL_EXPENSE_SUM", actualExpenseSum);
    result:set("EXPENSE_DIFF_SUM", budgetExpenseSum - actualExpenseSum); -- negative if actual greater than budget
    
    local expenseVsIncomeRate = tonumber(string.format("%.2f", (actualExpenseSum / actualIncomeSum) * 100));
    local jsExpenseIncome = createChartForComparison("expense_income", "Expense % of Income", expenseVsIncomeRate);
    local jsExpenseIncomeSparkline = createSparklineChartForComparison("expense_income", expenseVsIncomeRate);
    result:set("EXPENSE_INCOME_DATA", jsExpenseIncome);
    result:set("EXPENSE_INCOME_SPARKLINE_DATA", jsExpenseIncomeSparkline);
    result:set("EXPENSE_INCOME_DIFF_SUM", actualIncomeSum - actualExpenseSum); -- negative if actual expense greater than actual income
    
    result:set("DASHBOARD_DATA", dashboardChartsJsOutput);
end

---
-- generates the css style code, which set the currency symbol for all .money classed html elements.
-- 
function generateCurrencyCss() 
    local currencyCss = "";
    local currencyTemplate = [==[
        .money:before {
            content: "%s";
        }
        .money:after {
            content: "%s";
        }
    ]==];
    
    return currencyTemplate:format(baseCurrencyPrefixSymbol, baseCurrencySuffixSymbol);
end

---
-- Create the javascript chart code for comparison of two values. The given title is used as chart
-- title, the type specifies if its a expense or income chart (regarding color definition).
-- 
-- @param #string type type of color definition expenses or income
-- @param #string title the title of the chart
-- @param #float rate the actual rate of the budget
-- 
function createChartForComparison(type, title, rate)
    local template = [==[
        const %sRateOptions = {
            series: [%f],
            chart: {
                height: 350,
                type: 'radialBar',
                animations: {
                    enabled: false,
                },
            },
            plotOptions: {
                radialBar: {
                    hollow: {
                        size: '60%%',
                    },
                    dataLabels: {
                        show: true,
                        name: {
                            offsetY: 25,
                            color: '#5cb85c',
                        },
                        value: {
                            offsetY: -25,
                            fontSize: '36px',
                            formatter: function(value) {
                                return '%s%%';
                            }
                        },
                    },
                    track: {
                        background: '%s',
                        opacity: 0.7,
                    }
                },
            },
            colors: ['%s'],
            labels: ['%s'],
        };
        new ApexCharts(document.querySelector("#%s-rate"), %sRateOptions).render();
    ]==];
    
    local colorDefinition = expenseColors;
    if type == "income" then
        colorDefinition = incomeColors;
    end
   
    local barRate = rate;
    local barColor = determineColor(colorDefinition, rate);
    local backgroundColor = '#EEEEEE'
    if rate > 100 then
        barRate = rate - 100;
        backgroundColor = determineColor(colorDefinition, 100);
    end
    
    
    local js = string.format(template
        , type
        , barRate
        , rate
        , backgroundColor
        , barColor
        , title
        , type
        , type
    );

    return js;
end

---
-- Create the javascript chart code for comparison of two values as sparkline chart: only chart, no labels etc..
-- 
-- @param #string type type of color definition expenses or income
-- @param #string title the title of the chart
-- @param #float rate the actual rate of the budget
-- 
function createSparklineChartForComparison(type, rate)
    local template = [==[
        const %sRateSparklineOptions = {
            series: [%f],
            chart: {
                height: 50,
                width: 50,
                type: 'radialBar',
                animations: {
                    enabled: false,
                },
                sparkline: {
                  enabled: true,
                },
            },
            dataLabels: {
                enabled: false,
            },
            plotOptions: {
                radialBar: {
                    dataLabels: {
                        show: false,
                    },
                    track: {
                        margin: 0,
                        background: '%s',
                        opacity: 0.7,
                    }
                },
            },
            colors: ['%s'],
        };
        new ApexCharts(document.querySelector("#%s-rate-sparkline"), %sRateSparklineOptions).render();
    ]==];
    
    local colorDefinition = expenseColors;
    if type == "income" then
        colorDefinition = incomeColors;
    end
   
    local barRate = rate;
    local barColor = determineColor(colorDefinition, rate);
    local backgroundColor = '#EEEEEE'
    if rate > 100 then
        barRate = rate - 100;
        backgroundColor = determineColor(colorDefinition, 100);
    end
    
    
    local js = string.format(template
        , type
        , barRate
        , backgroundColor
        , barColor
        , type
        , type
    );

    return js;
end

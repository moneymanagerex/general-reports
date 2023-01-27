/**
 * Budget: One month is calculated by 365 / 12 = 30.41667, so that one month contains 30.41667 days.
 *      This value will be used to calculate weekly, bi-weekly or daily budget for a month.
 */
/**
 * All nested categories with Id of the parent category and Id/ Name of the root category.
 */
WITH categories AS (
    SELECT a.categid, a.categname, a.parentid, a.categid rootCategId, a.categName rootCategName 
    FROM category_v1 a 
    WHERE parentid = '-1' 
    UNION ALL 
    SELECT c.categid, r.categname || ':' || c.categname categName, c.parentid, r.rootCategId, r.rootCategName 
    FROM categories r
        join category_v1 c on (r.categid = c.parentid)
),
/**
 * Defines account types, which should not to be contained within the report. Several account types
 * can be combined with UNION ALL
 * You can list all used account types with 'select distinct accountType from AccountList_v1'
 * from the General Report Manager.
 */
ignoredAccountTypes AS (
    SELECT '<accountTypeToIgnore>' accountType
),
/**
 * Defines accounts by its account name, which should not to be contained within the report.
 * Several accounts can be combined with UNION ALL.
 */
ignoredAccountNames AS (
    SELECT '<accontNameToIgnore>' accountName 
),
/**
 * Defines the nested-category referenced by '<root category-name>:<sub-category-name>[:<sub-sub-category-name>]) 
 * which should be used as category for the given transaction code (Withdrawal or Deposit). 
 */
transferSubCategoriesToSubstitute AS (
    SELECT '<TransferSubCategoryName>' newCategoryName, 
        '<TransferCategoryName>:<TransferSubCategoryName>' transferCategoryName, '<TransactionCode>' transactionCode
),
transferSubstitution AS (
    select newCategoryName categoryName, c.categId categoryId, transactionCode
    from Categories c
        join transferSubCategoriesToSubstitute sub on (c.categName = sub.transferCategoryName)
),
/**
 * SubCategories, which are used in transfer transactions, should be nonetheless assigned to the category
 */
transferSubCategoriesToReAssign AS (
    SELECT '<CategoryName>:<TransferSubCategoryName>' TransferCategoryName 
),
/**
 * PeriodSelection: 
 *  * begin_date: Start of month of the selected start date
 *  * end_date: End of month of the selected end date 
 */
PeriodSelection as (
    select date('&begin_date', 'start of month') begin_date
        , date('&end_date', 'start of month', '+1 month', '-1 day') end_date
), 
/**
 * Integers incrementing starting from 1
 */
integers as (
    select 1 num union all select num + 1 from integers
),
/**
 * Months numbers from 1 to 12
 */
months as (
    select num month from integers limit 12
),
/**
 * SelectedBudgetMonths: 
 *  * each yearly budgets will be split into monthly budgets
 *  * all monthly budgets within the selected period 
 */
SelectedBudgetMonths as (
    SELECT BudgetYearId, BudgetMonthName
    FROM (
        -- If there is a specific budget for a month and a yearly budget (which is split into monthly budget)
        -- use the specifiv budget from the month
        SELECT BudgetYearId, BudgetMonthName, IsBudgetTypeMonth
            , max(IsBudgetTypeMonth) OVER (PARTITION BY BudgetMonthName) BudgetTypeMonthToSelect 
        FROM (
            select BudgetYearId, BudgetYearName BudgetMonthName, 1 IsBudgetTypeMonth
            from BudgetYear_v1
            WHERE 1=1
                AND length(BudgetYearName) = 7 -- yyyy-mm
            UNION ALL
            -- Split yearly budget into monthly budgets
            SELECT BudgetYearId, printf('%d-%02d', BudgetYearName, month) BudgetMonthName, 0 IsBudgetTypeMonth
            FROM BudgetYear_v1 JOIN months
            WHERE 1=1
                AND length(BudgetYearName) = 4 -- yyyy
        )
        WHERE date(BudgetMonthName || '-01') 
            BETWEEN (select begin_date from PeriodSelection limit 1)
            AND (select end_date from PeriodSelection limit 1)
    )
    WHERE IsBudgetTypeMonth = BudgetTypeMonthToSelect
), 
/**
 * Each category is mapped to either Withdrawal or Deposit. If both transaction codes are assigned
 * to transactions of the same category, the transaction code will be mapped, which contains more
 * transactions.
 */
transactionTypesOfCategories AS (
    select TransCode, categId CategoryId, categName Category
    from (
        select categId, categName, transcode, numberOfTransactions, max(numberOfTransactions) over (partition by categId, categName) numberOfTransactionsForMainTransCode
        from (
            select transCode, c.rootCategId categId, c.rootCategName categName, count(transid) numberOfTransactions
            from categories c 
                join checkingaccount_v1 ca on (c.categId = ca.categId)
            where 1=1
                and transcode <> 'Transfer'
            group by transcode, c.rootCategId, c.rootCategName
        )
    )
    where 1=1
        and numberOfTransactions = numberOfTransactionsForMainTransCode
    UNION ALL
    select transactionCode, categoryId, categoryName category
    FROM transferSubstitution
),
/**
 * Select all actual amounts of non-void transactions within the selected time period for accounts, which are not ignored:
 *  * non-Transfer transactions 
 *  * Transfer transactions, re-assigned to the non-transfer category
 *  * Transfer transactions, substituted as separate category
 */
actuals AS (
    select a.AccountName, c.RootCategId CategoryId, c.RootCategName category
        , ifnull(abs(st.SplitTransAmount), t.TransAmount) * cf.BaseConvRate BasedTransAmount
        , CASE WHEN t.TransCode = ttc.TransCode THEN 1 ELSE -1 END sign
    from (checkingaccount_v1 t
        left join SplitTransactions_v1 st on (t.TransId = st.TransId))
        join Categories c on (c.CategId = ifnull(st.CategId, t.CategId))
        JOIN transactionTypesOfCategories ttc ON (c.RootCategId = ttc.CategoryId)
        join AccountList_v1 a on (t.AccountId = a.AccountId)
        join CurrencyFormats_v1 cf on (a.CurrencyId = cf.CurrencyId)
    where 1=1
        and t.TransCode <> 'Transfer'
        and t.Status <> 'V'
        AND ifnull(t.deletedtime, '') = ''
        and TransDate between (select begin_date from PeriodSelection limit 1) and (select end_date from PeriodSelection limit 1)
        AND a.accountType NOT IN (SELECT accountType FROM IgnoredAccountTypes)
        AND a.accountName NOT IN (SELECT accountName FROM IgnoredAccountNames)
    UNION ALL
    select a.AccountName, c.RootCategId CategoryId, c.RootCategName category
        , ifnull(abs(st.SplitTransAmount), t.TransAmount) * cf.BaseConvRate BasedTransAmount
        , 1 sign
    from (checkingaccount_v1 t
        left join SplitTransactions_v1 st on (t.TransId = st.TransId))
        join Categories c on (c.CategId = ifnull(st.CategId, t.CategId))
        JOIN transferSubCategoriesToReAssign tsc ON (c.CategName = tsc.TransferCategoryName)
        JOIN transactionTypesOfCategories ttc ON (c.RootCategId = ttc.CategoryId)
        join AccountList_v1 a on (t.AccountId = a.AccountId)
        join CurrencyFormats_v1 cf on (a.CurrencyId = cf.CurrencyId)
    where 1=1
        and t.TransCode = 'Transfer'
        and t.Status <> 'V'
        AND ifnull(t.deletedtime, '') = ''
        and TransDate between (select begin_date from PeriodSelection limit 1) and (select end_date from PeriodSelection limit 1)
        AND a.accountType NOT IN (SELECT accountType FROM IgnoredAccountTypes)
        AND a.accountName NOT IN (SELECT accountName FROM IgnoredAccountNames)
    UNION all
    select a.AccountName, ts.CategoryId CategoryId, ts.CategoryName category
        , ifnull(abs(st.SplitTransAmount), t.TransAmount) * cf.BaseConvRate BasedTransAmount
        , 1 sign
    from (checkingaccount_v1 t
        left join SplitTransactions_v1 st on (t.TransId = st.TransId))
        join Categories c on (c.CategId = ifnull(st.CategId, t.CategId))
        join AccountList_v1 a on (t.AccountId = a.AccountId)
        join CurrencyFormats_v1 cf on (a.CurrencyId = cf.CurrencyId)
        JOIN transferSubstitution ts ON (ts.CategoryId = c.categId)
    WHERE 1=1
        AND t.TransCode = 'Transfer'
        AND t.Status <> 'V'
        AND ifnull(t.deletedtime, '') = ''
        and TransDate between (select begin_date from PeriodSelection limit 1) and (select end_date from PeriodSelection limit 1)
        AND a.accountType NOT IN (SELECT accountType FROM IgnoredAccountTypes)
        AND a.accountName NOT IN (SELECT accountName FROM IgnoredAccountNames)
),
/**
 * Sum up actual amount by category. If the transaction code of a transaction doesn't match
 * the transaction code for the category, this amount will reduce the total
 */
actualsByCategory AS (
    select CategoryId, Category, round(total(BasedTransAmount * sign), 2) ActualAmount
    from actuals
    group by CategoryId, Category
),
/**
 * Budget totals by category normalized to months
 */
Budgets as (
    select bt.BudgetYearId, bt.CategId, Period
        , case 
              when Period = 'Weekly' then 30.41667 / 7
              when Period = 'Bi-Weekly' then 30.41667 / 7 / 2
              when Period = 'Fortnightly' then 30.41667 / 7 / 2
              when Period = 'Monthly' then 1 
              when Period = 'Bi-Monthly' then 1 / 2
              when Period = 'Every 2 Months' then 1 / 2
              when Period = 'Quarterly' then 1 / 3
              when Period = 'Half-Yearly' then 1 / 6
              when Period = 'Yearly' then 1 / 12
              when Period = 'Daily' then 30.41667
              WHEN Period = 'None' THEN 0
          end Factor
        , Amount
    from BudgetTable_v1 bt
        join SelectedBudgetMonths sbm on (bt.BudgetYearId = sbm.BudgetYearId)
),
/**
 * Budget totals by category normalized to months
 */
budgetsByCategory AS (
    select CategoryId, Category
        , round(total(abs(Amount * Factor)), 2) BudgetAmount
    from (
        select CategId, RootCategId CategoryId, RootCategName Category
        from Categories
        union all 
        SELECT CategoryId CategId, CategoryId, CategoryName Category
        from transferSubstitution
    ) c 
        join Budgets b on (c.CategId = b.CategId)
    group by CategoryId, Category
),
--    GROUP BY ts.CategoryId, ts.CategoryName
/**
 * actuals vs budgets for each category if one of the values exists
 */
actualsVsBudgets AS (
    SELECT dic.TransCode, dic.CategoryId, dic.Category Category
        , ifnull(ActualAmount, 0) ActualAmount, ifnull(BudgetAmount, 0) BudgetAmount
        , bcf.pfx_symbol BaseCurrencyPrefixSymbol
        , bcf.sfx_symbol BaseCurrencySuffixSymbol
    from transactionTypesOfCategories dic 
        join InfoTable_v1 it on (it.InfoName = 'BASECURRENCYID')
        join CurrencyFormats_v1 bcf on (it.InfoValue = bcf.CurrencyId)
        left join actualsByCategory d on (dic.CategoryId = d.CategoryId)
        left join budgetsByCategory b on (dic.CategoryId = b.CategoryId)
    where 1=0
        or ifnull(ActualAmount, 0) != 0
        or ifnull(BudgetAmount, 0) != 0
),
/**
 * the names of all accounts which actuals are used of 
 */
selectedAccounts AS (
    SELECT AccountName
    FROM actuals
    GROUP BY AccountName
),
reportData AS (
    select TransCode, CategoryId, Category
        , ActualAmount, BudgetAmount
        , CASE
            WHEN TransCode = 'Deposit' THEN ActualAmount - BudgetAmount
            ELSE BudgetAmount - ActualAmount
            END Difference
        , CASE 
            WHEN BudgetAmount = 0 THEN 1000
            ELSE round((ActualAmount / BudgetAmount) * 100, 2)
            END Rate
        , case 
            when BudgetAmount = 0 then 1 
            else (abs(ActualAmount - BudgetAmount) / BudgetAmount) 
            end RelativeDeviation
        , BaseCurrencyPrefixSymbol
        , BaseCurrencySuffixSymbol
        , 0 SwitchType
        , '' Type
    , 1 Show
    from actualsVsBudgets
    order by TransCode, Category
),
/**
 * Substitute date format patterns, which work in C++ but not in SQLite
 */
DateFormatSubstituted AS (
    SELECT replace(replace(replace(infovalue, 
        '%y', '%Y'), 
        '%Mon', '%m'), 
        '%w', '') format
        , infovalue, infoname
    FROM infotable_v1
    WHERE infoname = 'DATEFORMAT'
    LIMIT 1
)
SELECT *
FROM reportData
UNION ALL
SELECT '-- selected accounts --' TransCode, "" CategoryId
    , group_concat(AccountName, ', ') Category
    , 0 ActualAmount, 0 BudgetAmount, 0 Difference, 0 Rate, 0 RelativeDeviation
    , "" BaseCurrencyPrefixSymbol, "" BaseCurrencySuffixSymbol, 0 SwitchType, '' TYPE
    , 0 Show
FROM selectedAccounts
UNION ALL
SELECT '-- selected period --' TransCode, "" CategoryId
    , strftime(ifnull(format, '%y-%m-%d'), begin_date) || ' - ' || strftime(ifnull(format, '%y-%m-%d'), end_date) Category
    , 0 ActualAmount, 0 BudgetAmount, 0 Difference, 0 Rate, 0 RelativeDeviation
    , "" BaseCurrencyPrefixSymbol, "" BaseCurrencySuffixSymbol, 0 SwitchType, '' TYPE
    , 0 Show
FROM PeriodSelection
    left join DateFormatSubstituted on (1=1)
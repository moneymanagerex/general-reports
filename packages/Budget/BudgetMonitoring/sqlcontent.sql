/**
 * Budget: One month is calculated by 365 / 12 = 30.41667, so that one month contains 30.41667 days.
 *      This value will be used to calculate weekly, bi-weekly or daily budget for a month.
 */
/**
 * Defines account types, which should not to be contained within the report. Several account types
 * can be combined with UNION ALL
 * You can list all used account types with 'select distinct accountType from AccountList_v1'
 * from the General Report Manager.
 */
WITH ignoredAccountTypes AS (
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
 * Defines the sub-category referenced by tupel (category-name, sub-category-name) which should be used as 
 * category for the given transaction code (Withdrawal or Deposit). 
 */
transferSubCategoriesToSubstitute AS (
    SELECT '<TransferCategoryName>' transferCategoryName, '<TransferSubCategoryName>' transferSubCategoryName
        , '<TransactionCode>' transactionCode
),
transferSubstitution AS (
    select transferSubCategoryName categoryName, '0_' || sc.subCategId categoryId, transactionCode
        , c.categId, sc.subCategId
    from category_v1 c
        join subcategory_v1 sc on (c.categId = sc.categId)
        join transferSubCategoriesToSubstitute sub on (
            c.categName = sub.transferCategoryName and sc.subCategName = sub.transferSubCategoryName
        )
),
/**
 * SubCategories, which are used in transfer transactions, shoule be nonetheless assigned to the category
 */
transferSubCategoriesToReAssign AS (
    SELECT '<CategoryName>' CategoryName, '<TransferSubCategoryName>' transferSubCategoryName 
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
            select transCode, categId, categName, count(transid) numberOfTransactions
            from category_v1 
                join checkingaccount_v1 using (categId)
            where 1=1
                and transcode <> 'Transfer'
            group by transcode, categId, categName
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
    select a.AccountName, ifnull(st.CategId, t.CategId) CategoryId, c.CategName category
        , ifnull(abs(st.SplitTransAmount), t.TransAmount) * cf.BaseConvRate BasedTransAmount
        , CASE WHEN t.TransCode = ttc.TransCode THEN 1 ELSE -1 END sign
    from (checkingaccount_v1 t
        left join SplitTransactions_v1 st on (t.TransId = st.TransId))
        join Category_v1 c on (c.CategId = ifnull(st.CategId, t.CategId))
        JOIN transactionTypesOfCategories ttc ON (c.CategId = ttc.CategoryId)
        join AccountList_v1 a on (t.AccountId = a.AccountId)
        join CurrencyFormats_v1 cf on (a.CurrencyId = cf.CurrencyId)
    where 1=1
        and t.TransCode <> 'Transfer'
        and t.Status <> 'V'
        and TransDate between (select begin_date from PeriodSelection limit 1) and (select end_date from PeriodSelection limit 1)
        AND a.accountType NOT IN (SELECT accountType FROM IgnoredAccountTypes)
        AND a.accountName NOT IN (SELECT accountName FROM IgnoredAccountNames)
    UNION ALL
    select a.AccountName, ifnull(st.CategId, t.CategId) CategoryId, c.CategName category
        , ifnull(abs(st.SplitTransAmount), t.TransAmount) * cf.BaseConvRate BasedTransAmount
        , 1 sign
    from (checkingaccount_v1 t
        left join SplitTransactions_v1 st on (t.TransId = st.TransId))
        join Category_v1 c on (c.CategId = ifnull(st.CategId, t.CategId))
        JOIN SubCategory_v1 sc ON (sc.SubCategId = ifnull(st.SubCategId, t.SubCategId))
        JOIN transferSubCategoriesToReAssign tsc ON (c.CategName = tsc.CategoryName AND sc.SubCategName = tsc.transferSubCategoryName)
        JOIN transactionTypesOfCategories ttc ON (c.CategId = ttc.CategoryId)
        join AccountList_v1 a on (t.AccountId = a.AccountId)
        join CurrencyFormats_v1 cf on (a.CurrencyId = cf.CurrencyId)
    where 1=1
        and t.TransCode = 'Transfer'
        and t.Status <> 'V'
        and TransDate between (select begin_date from PeriodSelection limit 1) and (select end_date from PeriodSelection limit 1)
        AND a.accountType NOT IN (SELECT accountType FROM IgnoredAccountTypes)
        AND a.accountName NOT IN (SELECT accountName FROM IgnoredAccountNames)
    UNION all
    select a.AccountName, ts.CategoryId CategoryId, ts.CategoryName category
        , ifnull(abs(st.SplitTransAmount), t.TransAmount) * cf.BaseConvRate BasedTransAmount
        , 1 sign
    from (checkingaccount_v1 t
        left join SplitTransactions_v1 st on (t.TransId = st.TransId))
        join Category_v1 c on (c.CategId = ifnull(st.CategId, t.CategId))
        join AccountList_v1 a on (t.AccountId = a.AccountId)
        join CurrencyFormats_v1 cf on (a.CurrencyId = cf.CurrencyId)
        JOIN transferSubstitution ts ON (ts.CategId = ifnull(st.CategId, t.CategId) AND ts.SubCategId = ifnull(st.SubCategId, t.SubCategId))
    WHERE 1=1
        AND t.TransCode = 'Transfer'
        AND t.Status <> 'V'
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
budgetsByCategory AS (
    select c.CategId CategoryId, c.CategName Category
        , round(total(abs(
            case 
                when Period = 'Weekly' then Amount * 30.41667 / 7
                when Period = 'Bi-Weekly' then Amount * 30.41667 / 7 / 2
                when Period = 'Fortnightly' then Amount * 30.41667 / 7 / 2
                when Period = 'Monthly' then Amount 
                when Period = 'Bi-Monthly' then Amount / 2
                when Period = 'Every 2 Months' then Amount / 2
                when Period = 'Quarterly' then Amount / 3
                when Period = 'Half-Yearly' then Amount / 6
                when Period = 'Yearly' then Amount / 12
                when Period = 'Daily' then Amount * 30.41667
                WHEN Period = 'None' THEN 0
            end
        )), 2) BudgetAmount
    from BudgetTable_v1 bt
        join selectedBudgetMonths sbm on (bt.BudgetYearId = sbm.BudgetYearId)
        join Category_v1 c on (bt.CategId = c.CategId)
        left join SubCategory_v1 sc on (bt.SubCategId = sc.SubCategId)
    group by c.CategId, c.CategName
    UNION ALL
    SELECT ts.CategoryId, ts.CategoryName Category
        , round(total(abs(
            case 
                when Period = 'Weekly' then Amount * 30.41667 / 7
                when Period = 'Bi-Weekly' then Amount * 30.41667 / 7 / 2
                when Period = 'Fortnightly' then Amount * 30.41667 / 7 / 2
                when Period = 'Monthly' then Amount 
                when Period = 'Bi-Monthly' then Amount / 2
                when Period = 'Every 2 Months' then Amount / 2
                when Period = 'Quarterly' then Amount / 3
                when Period = 'Half-Yearly' then Amount / 6
                when Period = 'Yearly' then Amount / 12
                when Period = 'Daily' then Amount * 30.41667
                WHEN Period = 'None' THEN 0
            end
        )), 2) BudgetAmount
    FROM BudgetTable_v1 bt
        join selectedBudgetMonths sbm on (bt.BudgetYearId = sbm.BudgetYearId)
        JOIN transferSubstitution ts ON (ts.CategId = bt.CategId AND ts.SubCategId = bt.SubCategId)
    GROUP BY ts.CategoryId, ts.CategoryName
),
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
        , '' TYPE
        , 1 Show
    from actualsVsBudgets
    order by TransCode, Category
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

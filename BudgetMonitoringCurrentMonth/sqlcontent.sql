/**
 * Budget: One month is calculated by 365 / 12 = 30.41667, so that one month contains 30.41667 days.
 *      This value will be used to calculate weekly, bi-weekly or daily budget for a month.
 */
select dic.TransCode, dic.CategoryId, dic.Category Category
    , ifnull(round(ActualAmount, 2), 0) ActualAmount, ifnull(round(BudgetAmount, 2), 0) BudgetAmount
    , ifnull(round((ifnull(ActualAmount, 0) / BudgetAmount) * 100, 2), 1000) Rate
    , case 
            when ifnull(BudgetAmount, 0) = 0 
            then 1 
            else (abs(ifnull(ActualAmount, 0) - ifnull(BudgetAmount, 0)) / BudgetAmount) 
        end relativeDeviation
    , bcf.pfx_symbol BaseCurrencyPrefixSymbol
    , bcf.sfx_symbol BaseCurrencySuffixSymbol
from (
    select distinct TransCode, CategId CategoryId, CategName category 
    from category_v1 
        join checkingaccount_v1 using (CategId) 
    where 1=1
        and TransCode <> 'Transfer'
) dic 
    join InfoTable_v1 it on (it.InfoName = 'BASECURRENCYID')
    join CurrencyFormats_v1 bcf on (it.InfoValue = bcf.CurrencyId)
    left join (
        select CategoryId, Category, total(BasedTransAmount) ActualAmount
        from (
            select ifnull(st.CategId, t.CategId) CategoryId, c.CategName category
                , ifnull(st.SplitTransAmount, t.TransAmount) * cf.BaseConvRate BasedTransAmount
            from (checkingaccount_v1 t
                left join SplitTransactions_v1 st on (t.TransId = st.TransId))
                join Category_v1 c on (c.CategId = ifnull(st.CategId, t.CategId))
                join AccountList_v1 a on (t.AccountId = a.AccountId)
                join CurrencyFormats_v1 cf on (a.CurrencyId = cf.CurrencyId)
            where 1=1
                and t.TransCode <> 'Transfer'
                and t.STATUS NOT IN ('D', 'V')
                and TransDate 
                    between date('now', '0 month', 'start of month') 
                    and date('now', 'start of month', '1 month', '-1 day')
        )
        group by CategoryId, Category
    ) d on (dic.CategoryId = d.CategoryId)
    left join (
        select c.CategId CategoryId
            , c.CategName Category
            , total(abs(
                case 
                    when Period = 'Weekly' then Amount * 30.41667 / 7
                    when Period = 'Bi-Weekly' then Amount * 30.41667 / 7 / 2
                    when Period = 'Monthly' then Amount 
                    when Period = 'Bi-Monthly' then Amount / 2
                    when Period = 'Quarterly' then Amount / 3
                    when Period = 'Half-Yearly' then Amount / 6
                    when Period = 'Yearly' then Amount / 12
                    when Period = 'Daily' then Amount * 30.41667
                end
            )) BudgetAmount
        from BudgetTable_v1 bt
            join BudgetYear_v1 by on (bt.BudgetYearId = by.BudgetYearId)
            join Category_v1 c on (bt.CategId = c.CategId)
        where 1=1
            and by.BudgetYearName = strftime('%Y-%m', date('now', '0 month'))
        group by c.CategId, c.CategName
    ) b on (dic.CategoryId = b.CategoryId)
where 1=0
    or ifnull(ActualAmount, 0) != 0
    or ifnull(BudgetAmount, 0) != 0
order by dic.TransCode, relativeDeviation desc, dic.Category
;
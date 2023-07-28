
SELECT bq.categid,  bq.categname, ifnull(TransAmount,0) TransAmount, ifnull(round(BudgetAmount, 2), 0) BudgetAmount
FROM (
WITH RECURSIVE categories(categid, categname, parentid) AS 
(SELECT a.categid, a.categname, a.parentid FROM category_v1 a WHERE parentid = '-1' 
UNION ALL 
SELECT c.categid, r.categname || ':' || c.categname, c.parentid 
FROM categories r, category_v1 c 
WHERE r.categid = c.parentid) 
 SELECT categid, categname FROM categories ORDER by categname
) bq
LEFT JOIN (
            select CategID categoryID , Category
                , round(SUM(Amount),2) TransAmount
            from alldata 
            where 1=1
                and Status <> 'V'
                and Date 
                    between date('2021-01-01') 
                    and date('2021-12-31')
           group by categid
) d on (bq.categid = d.CategoryId)
LEFT JOIN (
      select c.categid categoryId, c.categName category
            , total(
                case 
                    when Period = 'Weekly' then Amount * 52
                    when Period = 'Bi-Weekly' then Amount * 26
                    when Period = 'Monthly' then Amount *12 
                    when Period = 'Bi-Monthly' then Amount * 6
                    when Period = 'Quarterly' then Amount *4 
                    when Period = 'Half-Yearly' then Amount * 2 
                    when Period = 'Yearly' then Amount
                    when Period = 'Daily' then Amount * 365
                end
            ) BudgetAmount
        from BudgetTable_v1 bt
            left join BudgetYear_v1 by on (bt.BudgetYearId = by.BudgetYearId)
            left join category_v1 c on (bt.categId = c.categId)
        where 1=1
            and by.BudgetYearName = strftime('%Y', date('2021-12-31'))
        group by c.categId
) b on (bq.categid = b.categoryId)

order by bq.categname


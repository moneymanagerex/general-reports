
SELECT bq.CategoryID,  bq.Category, bq.SubcategoryID, bq.subcategname, ifnull(TransAmount,0) TransAmount, ifnull(round(BudgetAmount, 2), 0) BudgetAmount
FROM (
select distinct cs.CategoryID,  cs.Category, cs.SubcategoryID, cs.subcategname
from (
select distinct c.CategId CategoryID, CategName Category, subcategid SubcategoryID, subcategname
from category_v1 c
join subcategory_v1 on subcategory_v1.categid = c.categid
UNION
select distinct c.CategId CategoryID, CategName Category, -1 SubcategoryID, "" subcategname
from category_v1 c
) cs
) bq
LEFT JOIN (
            select CategID categoryID , Category
                    ,  ifnull(SubCategID,-1) subcategoryid, Subcategory
                , round(SUM(Amount),2) TransAmount
            from alldata 
            where 1=1
                and Status <> 'V'
                and Date 
                    between date('2021-01-01') 
                    and date('2021-12-31')
           group by Category, Subcategory
) d on (bq.CategoryId = d.CategoryId) AND (bq.SubCategoryID = d.subcategoryid)
LEFT JOIN (
      select c.categid categoryId, c.categName category, ifnull(s.subcategId,-1) subcategoryId, s.subcategName subcategory
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
            left join subcategory_v1 s on (bt.subcategId = s.subcategId)
        where 1=1
            and by.BudgetYearName = strftime('%Y', date('2021-12-31'))
        group by c.categId, s.subcategid
) b on (bq.categoryId = b.categoryId) AND (bq.subcategoryId = b.subcategoryId)

order by bq.Category, bq.subcategname


-- TODO: Update category and subcategory name in line 19. 
select strftime('%Y', t1.TRANSDATE) as YEAR
    , strftime('%m', t1.TRANSDATE) as MONTH
    , total(t1.TRANSAMOUNT * c1.BASECONVRATE) 
    + (select total(split.SPLITTRANSAMOUNT * c2.BASECONVRATE) from CHECKINGACCOUNT_V1 as t2
       inner join ACCOUNTLIST_V1 as a2 on a2.ACCOUNTID = t1.ACCOUNTID
       inner join CURRENCYFORMATS_V1 as c2 on c2.CURRENCYID = a2.CURRENCYID
       inner join SPLITTRANSACTIONS_V1 as split on t2.TRANSID = split.TRANSID
       where strftime('%Y', t2.TRANSDATE) = strftime('%Y', t1.TRANSDATE)
       and strftime('%m', t2.TRANSDATE) = strftime('%m', t1.TRANSDATE)
       and split.CATEGID = cat.CATEGID
       and split.SUBCATEGID = subcat.SUBCATEGID
       and t2.STATUS <> 'V') as AMOUNT
from CHECKINGACCOUNT_V1 as t1
inner join ACCOUNTLIST_V1 as a1 on a1.ACCOUNTID = t1.ACCOUNTID
inner join CURRENCYFORMATS_V1 as c1 on c1.CURRENCYID = a1.CURRENCYID
inner join CATEGORY_V1 as cat on t1.CATEGID = cat.CATEGID
inner join SUBCATEGORY_V1 as subcat on t1.SUBCATEGID = subcat.SUBCATEGID
where cat.CATEGNAME = 'Food' and subcat.SUBCATEGNAME = 'Groceries'
    and t1.STATUS <> 'V'
group by year, month
order by year asc, month asc;

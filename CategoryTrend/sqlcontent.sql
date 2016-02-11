-- TODO: Update category and subcategory name in line 17. 
select strftime('%Y', TRANSDATE) as YEAR
    , strftime('%m', TRANSDATE) as MONTH
    , total((case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) * c1.BASECONVRATE) as AMOUNT
from
    (select ACCOUNTID, TRANSDATE, TRANSCODE, CATEGID, SUBCATEGID, TRANSAMOUNT from CHECKINGACCOUNT_V1
        where STATUS <> 'V'
    union all
    select t1.ACCOUNTID, t1.TRANSDATE, t1.TRANSCODE, t2.CATEGID, t2.SUBCATEGID, t2.SPLITTRANSAMOUNT from SPLITTRANSACTIONS_V1 as t2
        inner join CHECKINGACCOUNT_V1 as t1
        on t1.TRANSID = t2.TRANSID
        where t1.STATUS <> 'V') as t3
inner join ACCOUNTLIST_V1 as a1 on a1.ACCOUNTID = t3.ACCOUNTID
inner join CURRENCYFORMATS_V1 as c1 on c1.CURRENCYID = a1.CURRENCYID
inner join CATEGORY_V1 as cat on t3.CATEGID = cat.CATEGID
inner join SUBCATEGORY_V1 as subcat on t3.SUBCATEGID = subcat.SUBCATEGID
where cat.CATEGNAME = 'Food' and subcat.SUBCATEGNAME = 'Groceries'
group by year, month
order by year asc, month asc;
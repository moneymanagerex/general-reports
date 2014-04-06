select s1.STOCKNAME, s1.SYMBOL,
    total(s1.NUMSHARES) as NUMSHARES,
    total(s1.VALUE * c1.BASECONVRATE) as VALUE
from ACCOUNTLIST_V1 as a1
inner join  STOCK_V1 as s1 on s1.HELDAT = a1.ACCOUNTID
inner join CURRENCYFORMATS_V1 as c1 on c1.CURRENCYID = a1.CURRENCYID
where a1.ACCOUNTTYPE = 'Investment' and a1.STATUS = 'Open'
group by s1.SYMBOL
order by VALUE desc;

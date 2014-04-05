select c.CURRENCYNAME, c.CURRENCY_SYMBOL, count(*) as Quantity, c.BASECONVRATE
from CURRENCYFORMATS_V1 as c
inner join ACCOUNTLIST_V1 as a on a.CURRENCYID = c.CURRENCYID
where a.STATUS = 'Open'
group by c.CURRENCYNAME
order by c.CURRENCYNAME asc;

select s1.STOCKNAME, s1.SYMBOL,
    total(s1.NUMSHARES) as NUMSHARES,
    total(s1.VALUE * IFNULL(CH.CURRVALUE, c1.BASECONVRATE)) as VALUE
from ACCOUNTLIST_V1 as a1
inner join  STOCK_V1 as s1 on s1.HELDAT = a1.ACCOUNTID
inner join CURRENCYFORMATS_V1 as c1 on c1.CURRENCYID = a1.CURRENCYID
left join CURRENCYHISTORY_V1 AS CH ON CH.CURRENCYID = c1.CURRENCYID AND 
                                   CH.CURRDATE = (
                                                     SELECT MAX(CRHST.CURRDATE) 
                                                       FROM CURRENCYHISTORY_V1 AS CRHST
                                                      WHERE CRHST.CURRENCYID = c1.CURRENCYID
                                                 )
where a1.ACCOUNTTYPE = 'Investment' and a1.STATUS = 'Open'
group by s1.SYMBOL
order by VALUE desc;
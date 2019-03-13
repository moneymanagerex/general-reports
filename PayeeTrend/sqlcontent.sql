-- TODO: Update payee name in line 19. 
select strftime('%Y', t.TRANSDATE) as YEAR
    , total(case when '01' = strftime('%m', t.TRANSDATE) then t.TRANSAMOUNT * c.BASECONVRATE else null end) as Jan
    , total(case when '02' = strftime('%m', t.TRANSDATE) then t.TRANSAMOUNT * c.BASECONVRATE else null end) as Feb
    , total(case when '03' = strftime('%m', t.TRANSDATE) then t.TRANSAMOUNT * c.BASECONVRATE else null end) as Mar
    , total(case when '04' = strftime('%m', t.TRANSDATE) then t.TRANSAMOUNT * c.BASECONVRATE else null end) as Apr
    , total(case when '05' = strftime('%m', t.TRANSDATE) then t.TRANSAMOUNT * c.BASECONVRATE else null end) as May
    , total(case when '06' = strftime('%m', t.TRANSDATE) then t.TRANSAMOUNT * c.BASECONVRATE else null end) as Jun
    , total(case when '07' = strftime('%m', t.TRANSDATE) then t.TRANSAMOUNT * c.BASECONVRATE else null end) as Jul
    , total(case when '08' = strftime('%m', t.TRANSDATE) then t.TRANSAMOUNT * c.BASECONVRATE else null end) as Aug
    , total(case when '09' = strftime('%m', t.TRANSDATE) then t.TRANSAMOUNT * c.BASECONVRATE else null end) as Sep
    , total(case when '10' = strftime('%m', t.TRANSDATE) then t.TRANSAMOUNT * c.BASECONVRATE else null end) as Oct
    , total(case when '11' = strftime('%m', t.TRANSDATE) then t.TRANSAMOUNT * c.BASECONVRATE else null end) as Nov
    , total(case when '12' = strftime('%m', t.TRANSDATE) then t.TRANSAMOUNT * c.BASECONVRATE else null end) as Dec
from CHECKINGACCOUNT_V1 as t
inner join ACCOUNTLIST_V1 as a on a.ACCOUNTID = t.ACCOUNTID
inner join CURRENCYFORMATS_V1 as c on c.CURRENCYID = a.CURRENCYID
inner join  PAYEE_V1 as p on t.PAYEEID = p.PAYEEID
where p.PAYEENAME = 'Payee1'
    and t.TRANSCODE='Withdrawal'
    and t.STATUS NOT IN ('D', 'V')
group by year
order by year desc;

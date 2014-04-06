select a.ACCOUNTNAME, c.BASECONVRATE, c.PFX_SYMBOL, c.SFX_SYMBOL,
    (select a.INITIALBAL + total(t.TRANSAMOUNT)
    from
        (select ACCOUNTID, STATUS,
            (case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
        from CHECKINGACCOUNT_V1
        union all
        select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
        from CHECKINGACCOUNT_V1
        where TRANSCODE = 'Transfer') as t
    where  t.ACCOUNTID = a.ACCOUNTID
        and t.STATUS <> 'V') as Balance
from ACCOUNTLIST_V1 as a
inner join CURRENCYFORMATS_V1 as c on c.CURRENCYID = a.CURRENCYID
where a.ACCOUNTTYPE in ('Checking', 'Term') and a.STATUS = 'Open'
group by a.ACCOUNTNAME
order by a.ACCOUNTNAME asc;

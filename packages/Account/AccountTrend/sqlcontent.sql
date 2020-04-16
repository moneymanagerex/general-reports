-- TODO: Update account name in line 31.
select strftime('%Y', t1.TRANSDATE) as YEAR
    , strftime('%m', t1.TRANSDATE) as MONTH
    , c.PFX_SYMBOL, c.SFX_SYMBOL, c.DECIMAL_POINT, c.GROUP_SEPARATOR
    , total(t1.TRANSAMOUNT)
        + (select a.INITIALBAL + total(t2.TRANSAMOUNT)
            from
                (select ACCOUNTID, TRANSDATE, STATUS,
                    (case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
                from CHECKINGACCOUNT_V1
                union all
                select TOACCOUNTID, TRANSDATE, STATUS, TOTRANSAMOUNT 
                from CHECKINGACCOUNT_V1
                where TRANSCODE = 'Transfer') as t2
            where t2.ACCOUNTID = t1.ACCOUNTID
                and t2.STATUS NOT IN ('D', 'V')
                and (strftime('%Y', t2.TRANSDATE) < strftime('%Y', t1.TRANSDATE)
                    or (strftime('%Y', t2.TRANSDATE) = strftime('%Y', t1.TRANSDATE)
                        and strftime('%m', t2.TRANSDATE) < strftime('%m', t1.TRANSDATE)))
        ) as Balance, a.ACCOUNTNAME as ACCOUNTNAME
from
    (select ACCOUNTID, TRANSDATE, STATUS,
        (case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
    from CHECKINGACCOUNT_V1
    union all
    select TOACCOUNTID, TRANSDATE, STATUS, TOTRANSAMOUNT 
    from CHECKINGACCOUNT_V1
    where TRANSCODE = 'Transfer') as t1
inner join ACCOUNTLIST_V1 as a on a.ACCOUNTID = t1.ACCOUNTID
inner join CURRENCYFORMATS_V1 as c on c.CURRENCYID = a.CURRENCYID
where ACCOUNTNAME = 'Account1'
    and t1.STATUS NOT IN ('D', 'V')
group by YEAR, MONTH
order by YEAR asc, MONTH asc;

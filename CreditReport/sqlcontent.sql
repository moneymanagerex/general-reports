-- TODO: Update account names in line 16 and Lua.
select a.ACCOUNTNAME
    , a.INITIALBAL + total(t.TRANSAMOUNT) as Balance
    , (a.INITIALBAL + total(t.TRANSAMOUNT))*c.BASECONVRATE as BaseBal
    , c.PFX_SYMBOL, c.SFX_SYMBOL
from
    (select ACCOUNTID, TRANSDATE, STATUS,
        (case when TRANSCODE='Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
    from CHECKINGACCOUNT_V1
    union all
    select TOACCOUNTID, TRANSDATE, STATUS, TOTRANSAMOUNT
    from CHECKINGACCOUNT_V1
    where TRANSCODE='Transfer') as t
inner join ACCOUNTLIST_V1 as a on a.ACCOUNTID=t.ACCOUNTID
inner join CURRENCYFORMATS_V1 as c on a.CURRENCYID=c.CURRENCYID
where ACCOUNTNAME in ('Account1', 'Account2')
    and t.STATUS<>'V'
group by a.ACCOUNTID
order by ACCOUNTNAME;
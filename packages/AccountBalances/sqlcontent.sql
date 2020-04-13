with b as  (
    select ACCOUNTID, STATUS
        , (case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
        , TRANSDATE
    from CHECKINGACCOUNT_V1    
    where STATUS <> 'V'
        and TRANSDATE <= '&single_date'
    union all
    select TOACCOUNTID, STATUS
        , TOTRANSAMOUNT ,TRANSDATE
    from CHECKINGACCOUNT_V1
    where TRANSCODE = 'Transfer'
        and STATUS <> 'V'
        and TRANSDATE <= '&single_date'
    )
, c as (select CURRENCYID, PFX_SYMBOL, SFX_SYMBOL, CURRENCY_SYMBOL, DECIMAL_POINT, GROUP_SEPARATOR, SCALE from CURRENCYFORMATS_V1)
, r as ( select  cf.CURRENCYID, ifnull(ch.CURRVALUE, 1) CURRVALUE  from CURRENCYFORMATS_V1 cf
left join CURRENCYHISTORY_V1 ch on cf.CURRENCYID = ch.CURRENCYID 
    and ch.CURRDATE = (SELECT MAX(CURRDATE) FROM CURRENCYHISTORY_V1 WHERE CURRENCYID = ch.CURRENCYID) 
    and ch.CURRDATE <= '&single_date')
select a.ACCOUNTNAME, a.ACCOUNTTYPE,
total(TRANSAMOUNT) + a.INITIALBAL as BALANCE,
c.PFX_SYMBOL, c.SFX_SYMBOL, c.CURRENCY_SYMBOL, r.CURRVALUE, c.SCALE
from ACCOUNTLIST_V1 a
left join b on a.ACCOUNTID=b.ACCOUNTID
left join c on a.CURRENCYID=c.CURRENCYID
left join r on r.CURRENCYID=c.CURRENCYID
where a.STATUS = 'Open'  and a.ACCOUNTTYPE !='Investment'
group by a.ACCOUNTNAME 
order by a.ACCOUNTTYPE, a.ACCOUNTNAME asc;

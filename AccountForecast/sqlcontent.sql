-- TODO: Update account name in line 24. 
select b.TRANSAMOUNT, b.REPEATS, b.NUMOCCURRENCES, b.NEXTOCCURRENCEDATE, c.PFX_SYMBOL, c.SFX_SYMBOL,
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
        and t.STATUS NOT IN ('V','D')) as Balance
from 
    (select ACCOUNTID, STATUS, REPEATS, NUMOCCURRENCES, NEXTOCCURRENCEDATE,
        (case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
    from BILLSDEPOSITS_V1
    union all
    select TOACCOUNTID, STATUS, REPEATS, NUMOCCURRENCES, NEXTOCCURRENCEDATE, TOTRANSAMOUNT
    from BILLSDEPOSITS_V1
    where TRANSCODE = 'Transfer') as b
inner join  ACCOUNTLIST_V1 as a on b.ACCOUNTID = a.ACCOUNTID
inner join CURRENCYFORMATS_V1 as c on c.CURRENCYID = a.CURRENCYID
where a.ACCOUNTNAME = 'Account1'
and b.STATUS NOT IN ('V','D');

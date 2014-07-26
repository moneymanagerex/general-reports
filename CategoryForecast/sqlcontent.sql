-- USAGE: Update category name in line 15.
select TRANSAMOUNT, REPEATS, NUMOCCURRENCES, NEXTOCCURRENCEDATE,
    (select total(t.TRANSAMOUNT)
    from
        (select CATEGID, STATUS, TRANSDATE, 
            (case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
        from CHECKINGACCOUNT_V1) as t
    where t.CATEGID = a.CATEGID
        and t.STATUS <> 'V' AND t.TRANSDATE>=date('now','start of year')) as Balance
from
    (select CATEGID, STATUS, REPEATS, NUMOCCURRENCES, NEXTOCCURRENCEDATE,
        (case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
    from BILLSDEPOSITS_V1) as b
inner join CATEGORY_V1 as a on b.CATEGID = a.CATEGID
where a.CATEGNAME = 'Donations'
and b.STATUS <> 'V';
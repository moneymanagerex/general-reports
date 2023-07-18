select c.transid, c.transdate, c.notes
    , 'ERROR' as Account
    , 'OK' as category
    ,  p.PayeeName as Payee
    from checkingaccount_v1 c
    inner join payee_v1 p on p.payeeid=c.payeeid
    where c.accountid not in (select accountid from accountlist_v1)
union all
select c.transid, c.transdate, c.notes
    , 'ERROR' as Account
    , 'OK' as category
    ,  '' as Payee
    from checkingaccount_v1 c
    where c.transcode ='Transfer' and c.toaccountid not in (select accountid from accountlist_v1)
union all
select c.transid, c.transdate, c.notes
    , a.AccountName
    , 'OK' 
    ,  'ERROR' 
    from checkingaccount_v1 c
      inner join accountlist_v1 a on a.accountid=c.accountid
    where c.payeeid not in (select payeeid from payee_v1) and transcode!='Transfer'
union all
select c.transid, c.transdate, c.notes
     , a.AccountName
    , 'ERROR'
    ,  p.PayeeName
    from checkingaccount_v1 c
      inner join payee_v1 p on p.payeeid=c.payeeid
      inner join accountlist_v1 a on a.accountid=c.accountid
    where c.categid=-1 and c.transid not in (select transid from splittransactions_v1)
union all
select c.transid, c.transdate, c.notes
     , a.AccountName
    , 'ERROR'
    ,  p.PayeeName
    from checkingaccount_v1 c
      inner join payee_v1 p on p.payeeid=c.payeeid
      inner join accountlist_v1 a on a.accountid=c.accountid
    where c.categid > 0 and c.categid not in (select categid from category_v1)
union all
select c.transid, c.transdate, c.notes
     , a.AccountName
    , 'ERROR'
    ,  p.PayeeName
    from checkingaccount_v1 c
      inner join payee_v1 p on p.payeeid=c.payeeid
      inner join accountlist_v1 a on a.accountid=c.accountid
      inner join splittransactions_v1 s on c.transid=s.transid
    where s.categid > 0  and s.categid not in (select categid from category_v1);

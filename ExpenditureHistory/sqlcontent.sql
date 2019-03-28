SELECT cat.CATEGNAME as CATEGNAME,
       sum (case when (alltx.TRANSDATE >= date('now', 'start of month', '-0 month')) then alltx.TRANSAMOUNT else 0 end) as MonthAgo0,
       sum (case when (alltx.TRANSDATE >= date('now', 'start of month', '-1 month') AND alltx.TRANSDATE < date('now', 'start of month', '-0 month')) then alltx.TRANSAMOUNT else 0 end) as MonthAgo1,
       sum (case when (alltx.TRANSDATE >= date('now', 'start of month', '-2 month') AND alltx.TRANSDATE < date('now', 'start of month', '-1 month')) then alltx.TRANSAMOUNT else 0 end) as MonthAgo2,
       sum (case when (alltx.TRANSDATE >= date('now', 'start of month', '-3 month') AND alltx.TRANSDATE < date('now', 'start of month', '-2 month')) then alltx.TRANSAMOUNT else 0 end) as MonthAgo3,
       sum (case when (alltx.TRANSDATE >= date('now', 'start of month', '-4 month') AND alltx.TRANSDATE < date('now', 'start of month', '-3 month')) then alltx.TRANSAMOUNT else 0 end) as MonthAgo4,
       sum (case when (alltx.TRANSDATE >= date('now', 'start of month', '-5 month') AND alltx.TRANSDATE < date('now', 'start of month', '-4 month')) then alltx.TRANSAMOUNT else 0 end) as MonthAgo5,
       sum (case when (alltx.TRANSDATE >= date('now', 'start of month', '-6 month') AND alltx.TRANSDATE < date('now', 'start of month', '-5 month')) then alltx.TRANSAMOUNT else 0 end) as MonthAgo6,
       sum (case when (alltx.TRANSDATE >= date('now', 'start of month', '-7 month') AND alltx.TRANSDATE < date('now', 'start of month', '-6 month')) then alltx.TRANSAMOUNT else 0 end) as MonthAgo7,
       sum (case when (alltx.TRANSDATE >= date('now', 'start of month', '-7 month') AND alltx.TRANSDATE < date('now', 'start of month', '-0 month')) then alltx.TRANSAMOUNT else 0 end) as TOTAL,
       strftime('%m-%Y', date('now') ) AS date0,
       strftime('%m-%Y', date('now', 'start of month', '-1 month') ) AS date1,
       strftime('%m-%Y', date('now', 'start of month', '-2 month') ) AS date2,
       strftime('%m-%Y', date('now', 'start of month', '-3 month') ) AS date3,
       strftime('%m-%Y', date('now', 'start of month', '-4 month') ) AS date4,
       strftime('%m-%Y', date('now', 'start of month', '-5 month') ) AS date5,
       strftime('%m-%Y', date('now', 'start of month', '-6 month') ) AS date6,
       strftime('%m-%Y', date('now', 'start of month', '-7 month') ) AS date7
  FROM (
SELECT txdata.transid AS transid,
       txdata.transcode AS transcode,
       txdata.transamount AS transamount,
       txdata.basetransamount AS basetransamount,
       txdata.categid AS categid,
       txdata.transdate AS transdate
  FROM (SELECT tx.transid AS transid,
               tx.transcode AS transcode,
               CASE tx.categid WHEN -1 THEN st.splittransamount ELSE tx.transamount END AS transamount,
               (CASE tx.categid WHEN -1 THEN st.splittransamount ELSE tx.transamount END) * (ifnull(ch.currvalue, cf.baseconvrate) * 1.0) AS basetransamount,
               CASE tx.categid WHEN -1 THEN st.categid ELSE tx.categid END AS categid,
               tx.transdate AS transdate
          FROM checkingaccount_v1 AS tx
               LEFT JOIN splittransactions_v1 AS st ON tx.transid = st.transid
               LEFT JOIN accountlist_v1 AS acc ON tx.accountid = acc.accountid -- for toaccount convertion to base currency
               LEFT JOIN currencyformats_v1 AS cf ON acc.currencyid = cf.currencyid
               LEFT JOIN currencyhistory_v1 AS ch ON ch.currencyid = cf.currencyid
                                                  AND ch.currdate = ( SELECT max(crhst.currdate) FROM currencyhistory_v1 AS crhst WHERE crhst.currencyid = cf.currencyid)
             WHERE (tx.TRANSDATE >= date('now', 'start of month', '-7 month') AND tx.TRANSDATE < date('now'))
             AND tx.status NOT IN ('V','D')
             AND tx.transcode = 'Withdrawal'
       ) AS txdata
   ) AS alltx
   JOIN category_v1 AS cat on alltx.categid = cat.categid
GROUP BY cat.CATEGNAME
ORDER BY TOTAL DESC;

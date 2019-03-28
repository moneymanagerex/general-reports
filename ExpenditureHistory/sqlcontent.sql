SELECT cat.CATEGNAME as CATEGNAME,
       sum(case when (alltx.TRANSDATE >= rangedates.date0) then alltx.basetransamount else 0 end) as MonthAgo0,
       sum(case when (alltx.TRANSDATE >= rangedates.date1 AND alltx.TRANSDATE < rangedates.date0) then alltx.basetransamount else 0 end) as MonthAgo1,
       sum(case when (alltx.TRANSDATE >= rangedates.date2 AND alltx.TRANSDATE < rangedates.date1) then alltx.basetransamount else 0 end) as MonthAgo2,
       sum(case when (alltx.TRANSDATE >= rangedates.date3 AND alltx.TRANSDATE < rangedates.date2) then alltx.basetransamount else 0 end) as MonthAgo3,
       sum(case when (alltx.TRANSDATE >= rangedates.date4 AND alltx.TRANSDATE < rangedates.date3) then alltx.basetransamount else 0 end) as MonthAgo4,
       sum(case when (alltx.TRANSDATE >= rangedates.date5 AND alltx.TRANSDATE < rangedates.date4) then alltx.basetransamount else 0 end) as MonthAgo5,
       sum(case when (alltx.TRANSDATE >= rangedates.date6 AND alltx.TRANSDATE < rangedates.date5) then alltx.basetransamount else 0 end) as MonthAgo6,
       sum(case when (alltx.TRANSDATE >= rangedates.date7 AND alltx.TRANSDATE < rangedates.date6) then alltx.basetransamount else 0 end) as MonthAgo7,
       sum(alltx.basetransamount) as TOTAL,
       strftime('%m-%Y', rangedates.date0) AS date0,
       strftime('%m-%Y', rangedates.date1) AS date1,
       strftime('%m-%Y', rangedates.date2) AS date2,
       strftime('%m-%Y', rangedates.date3) AS date3,
       strftime('%m-%Y', rangedates.date4) AS date4,
       strftime('%m-%Y', rangedates.date5) AS date5,
       strftime('%m-%Y', rangedates.date6) AS date6,
       strftime('%m-%Y', rangedates.date7) AS date7
  FROM (SELECT sum((CASE tx.categid WHEN -1 THEN st.splittransamount ELSE tx.transamount END) * (ifnull(ch.currvalue, cf.baseconvrate) * 1.0)) AS basetransamount,
               CASE tx.categid WHEN -1 THEN st.categid ELSE tx.categid END AS categid,
               tx.transdate AS transdate
          FROM checkingaccount_v1 AS tx
               LEFT JOIN splittransactions_v1 AS st ON tx.transid = st.transid
               LEFT JOIN accountlist_v1 AS acc ON tx.accountid = acc.accountid -- for toaccount conversion to base currency
               LEFT JOIN currencyformats_v1 AS cf ON acc.currencyid = cf.currencyid
               LEFT JOIN currencyhistory_v1 AS ch ON ch.currencyid = cf.currencyid
                                                 AND ch.currdate = ( SELECT max(crhst.currdate) FROM currencyhistory_v1 AS crhst WHERE crhst.currencyid = cf.currencyid)
         WHERE (tx.TRANSDATE >= date('now', 'start of month', '-7 month') AND tx.TRANSDATE < date('now')) --ignore future transactions
           AND tx.status NOT IN ('V','D')
           AND tx.transcode = 'Withdrawal'
      GROUP BY (CASE tx.categid WHEN -1 THEN st.categid ELSE tx.categid END), tx.transdate
       ) AS alltx
  JOIN category_v1 AS cat on alltx.categid = cat.categid
  JOIN (SELECT date('now', 'start of month') AS date0,
               date('now', 'start of month', '-1 month') AS date1,
               date('now', 'start of month', '-2 month') AS date2,
               date('now', 'start of month', '-3 month') AS date3,
               date('now', 'start of month', '-4 month') AS date4,
               date('now', 'start of month', '-5 month') AS date5,
               date('now', 'start of month', '-6 month') AS date6,
               date('now', 'start of month', '-7 month') AS date7
       ) as rangedates
GROUP BY cat.CATEGNAME
ORDER BY TOTAL DESC;
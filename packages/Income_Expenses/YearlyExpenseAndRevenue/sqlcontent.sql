SELECT mdata.periode_month AS periode_month,
       sum(mdata.Total) AS Total,
       sum(mdata.Total_n1) AS Total_n1,
       sum(mdata.Total_n2) AS Total_n2,
       sum(mdata.Total_n3) AS Total_n3,
       sum(mdata.Total_n4) AS Total_n4,
       strftime('%Y', date('now', 'start of year', 'localtime') ) AS name_n0,
       strftime('%Y', date('now', 'start of year', '-1 year', 'localtime') ) AS name_n1,
       strftime('%Y', date('now', 'start of year', '-2 year', 'localtime') ) AS name_n2,
       strftime('%Y', date('now', 'start of year', '-3 year', 'localtime') ) AS name_n3,
       strftime('%Y', date('now', 'start of year', '-4 year', 'localtime') ) AS name_n4
  FROM (
           SELECT txd.periode_month,
                  CASE WHEN txd.periode_year = strftime('%Y', date('now', 'start of year', 'localtime') ) THEN txd.Deposit + txd.Withdrawal ELSE 0 END AS Total,
                  CASE WHEN txd.periode_year = strftime('%Y', date('now', 'start of year', '-1 year', 'localtime') ) THEN txd.Deposit + txd.Withdrawal ELSE 0 END AS Total_n1,
                  CASE WHEN txd.periode_year = strftime('%Y', date('now', 'start of year', '-2 year', 'localtime') ) THEN txd.Deposit + txd.Withdrawal ELSE 0 END AS Total_n2,
                  CASE WHEN txd.periode_year = strftime('%Y', date('now', 'start of year', '-3 year', 'localtime') ) THEN txd.Deposit + txd.Withdrawal ELSE 0 END AS Total_n3,
                  CASE WHEN txd.periode_year = strftime('%Y', date('now', 'start of year', '-4 year', 'localtime') ) THEN txd.Deposit + txd.Withdrawal ELSE 0 END AS Total_n4
             FROM (
                      SELECT strftime('%Y', ca.TRANSDATE) AS periode_year,
                             strftime('%m', ca.TRANSDATE) AS periode_month,
                             CASE WHEN ca.transcode = 'Deposit' THEN (ca.transamount * IFNULL(CH.CURRVALUE, CF.BASECONVRATE) * 1.0) ELSE 0 END AS Deposit,
                             CASE WHEN ca.transcode = 'Withdrawal' THEN - (ca.transamount * IFNULL(CH.CURRVALUE, CF.BASECONVRATE) * 1.0) ELSE 0 END AS Withdrawal
                        FROM CHECKINGACCOUNT_V1 AS ca
                             LEFT JOIN
                             ACCOUNTLIST_V1 AC ON AC.ACCOUNTID = ca.ACCOUNTID
                             LEFT JOIN
                             CURRENCYFORMATS_V1 cf ON cf.currencyid = AC.currencyid
                             LEFT JOIN
                             CURRENCYHISTORY_V1 AS CH ON CH.CURRENCYID = CF.CURRENCYID AND 
                                                         CH.CURRDATE = (
                                                                           SELECT MAX(CRHST.CURRDATE) 
                                                                             FROM CURRENCYHISTORY_V1 AS CRHST
                                                                            WHERE CRHST.CURRENCYID = CF.CURRENCYID
                                                                       )
                       WHERE ca.TRANSDATE >= date('now', 'start of year', '-4 year', 'localtime') AND 
                             ca.STATUS NOT IN ('V', 'D') AND 
                             ca.TRANSCODE <> 'Transfer'
                  )
                  AS txd
       )
       AS mdata
 GROUP BY mdata.periode_month
 ORDER BY mdata.periode_month ASC;
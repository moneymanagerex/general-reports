SELECT 'month' AS periode_name,
       cadata.periode AS periode,
       sum(cadata.Deposit) AS Deposit,
       sum(cadata.Withdrawal) AS Withdrawal,
       sum(cadata.Transfer) AS Transfer,
       round(sum(cadata.Deposit) + sum(cadata.Withdrawal) + sum(cadata.Transfer), 2) AS Total,
       (
           SELECT sum(al3.INITIALBAL) 
             FROM accountlist_V1 AS al3
       )
       AS initialbal
  FROM (
           SELECT strftime('%Y-%m', ca.TRANSDATE) AS periode,
                  CASE WHEN ca.transcode = 'Deposit' THEN ca.transamount ELSE 0 END AS Deposit,
                  CASE WHEN ca.transcode = 'Withdrawal' THEN -ca.transamount ELSE 0 END AS Withdrawal,
                  CASE WHEN ca.transcode = 'Transfer' AND 
                            ca.toaccountid IN (
                          SELECT al1.accountid
                            FROM accountlist_V1 AS al1
                           WHERE al1.accounttype = 'Loan'
                      )
                  THEN -ca.transamount WHEN ca.transcode = 'Transfer' AND 
                                            ca.accountid IN (
                          SELECT al2.accountid
                            FROM accountlist_V1 AS al2
                           WHERE al2.accounttype = 'Loan'
                      )
                  THEN ca.transamount ELSE 0 END AS Transfer
             FROM checkingaccount_V1 AS ca
            WHERE ca.STATUS NOT IN ('D', 'V')-- and TRANSDATE > date('now', 'start of month','-5 year','localtime') 
       )
       AS cadata
 GROUP BY periode
 ORDER BY periode ASC;

SELECT t.FOLLOWUPID,
       t.PAYEENAME,
       t.TRANSDATE,
       t.TRANSAMOUNT,
       t.TRANSAMOUNT * IFNULL(CH.CURRVALUE, c.BASECONVRATE) AS BaseAmount,
       c.PFX_SYMBOL,
       c.SFX_SYMBOL,
       (
           SELECT inf.infovalue
             FROM infotable_V1 AS inf
            WHERE inf.infoname = 'USER_COLOR' || CAST (t.followupid AS TEXT)
       )
       AS FOLLOWCOLOR,
t.transid as transid
  FROM (
           SELECT  (CASE WHEN c1.TRANSCODE = 'Transfer' THEN ' < ' ELSE '' END) || p.PAYEENAME AS PAYEENAME,
                  c1.TRANSDATE AS TRANSDATE,
                  c1.FOLLOWUPID AS FOLLOWUPID,
                  (CASE WHEN c1.TRANSCODE = 'Deposit' THEN c1.TRANSAMOUNT ELSE -c1.TRANSAMOUNT END) AS TRANSAMOUNT,
                  a1.CURRENCYID AS CURRENCYID,
		c1.TRANSID
             FROM CHECKINGACCOUNT_V1 AS c1
                  INNER JOIN
                  PAYEE_V1 AS p ON p.PAYEEID = c1.PAYEEID
                  INNER JOIN
                  ACCOUNTLIST_V1 AS a1 ON a1.ACCOUNTID = c1.ACCOUNTID
           UNION ALL
           SELECT ' > ' || a2.ACCOUNTNAME AS PAYEENAME,
                  c2.TRANSDATE,
                  c2.FOLLOWUPID,
                  c2.TOTRANSAMOUNT,
                  a2.CURRENCYID,
c2.TRANSID
             FROM CHECKINGACCOUNT_V1 AS c2
                  INNER JOIN
                  ACCOUNTLIST_V1 AS a2 ON a2.ACCOUNTID = c2.TOACCOUNTID
            WHERE TRANSCODE = 'Transfer'
       )
       AS t
       INNER JOIN
       CURRENCYFORMATS_V1 AS c ON t.CURRENCYID = c.CURRENCYID
       LEFT JOIN
       CURRENCYHISTORY_V1 AS CH ON CH.CURRENCYID = c.CURRENCYID AND
                                   CH.CURRDATE = (
                                                     SELECT MAX(CRHST.CURRDATE)
                                                       FROM CURRENCYHISTORY_V1 AS CRHST
                                                      WHERE CRHST.CURRENCYID = c.CURRENCYID
                                                 )
 WHERE t.FOLLOWUPID > 0
 ORDER BY t.FOLLOWUPID ASC,
          t.PAYEENAME ASC,
          t.TRANSDATE ASC;

SELECT IFNULL(CH.CURRVALUE, m.BASECONVRATE) AS CURRRATE,
    t.TRANSID,
       t.TRANSDATE,
       a.ACCOUNTNAME,
       p.PAYEENAME,
       t.NOTES,
       ((CASE t.TRANSCODE WHEN 'Deposit' THEN t.TRANSAMOUNT ELSE -t.TRANSAMOUNT END) * (IFNULL(CH.CURRVALUE, m.BASECONVRATE))) AS TRANSAMOUNT,
       m.PFX_SYMBOL,
       m.SFX_SYMBOL,
       m.GROUP_SEPARATOR,
       m.DECIMAL_POINT
  FROM CHECKINGACCOUNT_V1 AS t
       JOIN
       PAYEE_V1 AS p ON p.PAYEEID = t.PAYEEID
       JOIN
       ACCOUNTLIST_V1 AS a ON a.ACCOUNTID = t.ACCOUNTID
       JOIN
       CURRENCYFORMATS_V1 AS m ON m.CURRENCYID = a.CURRENCYID
       LEFT JOIN
       CURRENCYHISTORY_V1 AS CH ON CH.CURRENCYID = m.CURRENCYID AND 
                                   CH.CURRDATE = (
                                                     SELECT MAX(CRHST.CURRDATE) 
                                                       FROM CURRENCYHISTORY_V1 AS CRHST
                                                      WHERE CRHST.CURRENCYID = m.CURRENCYID
                                                 )
 WHERE t.STATUS="F";

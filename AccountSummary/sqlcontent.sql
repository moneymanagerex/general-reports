/* Setup: edit line 36 for the account types required */
SELECT a.ACCOUNTNAME,
       IFNULL(CH.CURRVALUE, c.BASECONVRATE) AS CURRVALUE, -- Remove this for v13 DB
       c.PFX_SYMBOL,
       c.SFX_SYMBOL,
       c.DECIMAL_POINT,
       c.GROUP_SEPARATOR,
       (
           SELECT a.INITIALBAL + total(t.TRANSAMOUNT) 
             FROM (
                      SELECT ACCOUNTID,
                             STATUS,
                             (CASE WHEN TRANSCODE = 'Deposit' THEN TRANSAMOUNT ELSE -TRANSAMOUNT END) AS TRANSAMOUNT
                        FROM CHECKINGACCOUNT_V1
                      UNION ALL
                      SELECT TOACCOUNTID,
                             STATUS,
                             TOTRANSAMOUNT
                        FROM CHECKINGACCOUNT_V1
                       WHERE TRANSCODE = 'Transfer'
                  )
                  AS t
            WHERE t.ACCOUNTID = a.ACCOUNTID AND 
                  t.STATUS NOT IN ('D', 'V') 
       )
       AS BALANCE
  FROM ACCOUNTLIST_V1 AS a
       INNER JOIN
       CURRENCYFORMATS_V1 AS c ON c.CURRENCYID = a.CURRENCYID
       LEFT JOIN
       CURRENCYHISTORY_V1 AS CH ON CH.CURRENCYID = c.CURRENCYID AND 
                                   CH.CURRDATE = (
                                                     SELECT MAX(CRHST.CURRDATE) 
                                                       FROM CURRENCYHISTORY_V1 AS CRHST
                                                      WHERE CRHST.CURRENCYID = c.CURRENCYID
                                                 )
 WHERE a.ACCOUNTTYPE IN ('Checking', 'Term') AND 
       a.STATUS = 'Open'
 GROUP BY a.ACCOUNTNAME
 ORDER BY a.ACCOUNTNAME ASC;

SELECT c.CURRENCYNAME AS CURRENCYNAME,
       c.CURRENCY_SYMBOL AS CURRENCY_SYMBOL,
       c.PFX_SYMBOL AS PFX_SYMBOL,
       c.SFX_SYMBOL AS SFX_SYMBOL,
       c.GROUP_SEPARATOR AS GROUP_SEPARATOR,
       c.DECIMAL_POINT AS DECIMAL_POINT,
       count( * ) AS Quantity,
       c.BASECONVRATE AS BASECONVRATE,
       IFNULL(CH.CURRVALUE, 0) AS HISTBASECONVRATE
  FROM CURRENCYFORMATS_V1 AS c
       INNER JOIN
       ACCOUNTLIST_V1 AS a ON a.CURRENCYID = c.CURRENCYID
       LEFT JOIN
       CURRENCYHISTORY_V1 AS CH ON C.CURRENCYID = CH.CURRENCYID AND 
                                   CH.CURRDATE = (
                                                     SELECT MAX(CRHST.CURRDATE) 
                                                       FROM CURRENCYHISTORY_V1 AS CRHST
                                                      WHERE CRHST.CURRENCYID = C.CURRENCYID
                                                 )
 WHERE a.STATUS = 'Open'
 GROUP BY c.CURRENCYNAME
 ORDER BY c.CURRENCYNAME ASC;

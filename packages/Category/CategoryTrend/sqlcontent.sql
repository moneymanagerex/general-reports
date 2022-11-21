-- TODO: Update category and subcategory name in line 35. 
WITH RECURSIVE categories(categid, categname, parentid) AS
    (SELECT a.categid, a.categname, a.parentid FROM category_v1 a WHERE parentid = '-1'
        UNION ALL
     SELECT c.categid, r.categname || ':' || c.categname, c.parentid
     FROM categories r, category_v1 c
	 WHERE r.categid = c.parentid
	 )
SELECT strftime('%Y', TRANSDATE) AS YEAR,
       strftime('%m', TRANSDATE) AS MONTH,
       total( (CASE WHEN TRANSCODE = 'Deposit' THEN TRANSAMOUNT ELSE -TRANSAMOUNT END) * IFNULL(CH.CURRVALUE, C1.BASECONVRATE) ) AS AMOUNT
  FROM (
           SELECT ACCOUNTID,
                  TRANSDATE,
                  TRANSCODE,
                  CATEGID,
                  TRANSAMOUNT
             FROM CHECKINGACCOUNT_V1
            WHERE STATUS NOT IN ('D', 'V')
			AND (DELETEDTIME = '' OR DELETEDTIME IS NULL)	
           UNION ALL
           SELECT t1.ACCOUNTID,
                  t1.TRANSDATE,
                  t1.TRANSCODE,
                  t2.CATEGID,
                  t2.SPLITTRANSAMOUNT
             FROM SPLITTRANSACTIONS_V1 AS t2
                  INNER JOIN
                  CHECKINGACCOUNT_V1 AS t1 ON t1.TRANSID = t2.TRANSID
            WHERE t1.STATUS NOT IN ('D', 'V') 
			AND (t1.DELETEDTIME = '' OR t1.DELETEDTIME IS NULL)
       )
       AS t3
       INNER JOIN ACCOUNTLIST_V1 AS a1 ON a1.ACCOUNTID = t3.ACCOUNTID
       INNER JOIN CURRENCYFORMATS_V1 AS c1 ON c1.CURRENCYID = a1.CURRENCYID
       INNER JOIN categories AS cat ON t3.CATEGID = cat.CATEGID
       LEFT JOIN CURRENCYHISTORY_V1 AS CH ON CH.CURRENCYID = C1.CURRENCYID AND 
                                   CH.CURRDATE = ( SELECT MAX(CRHST.CURRDATE) 
                                                       FROM CURRENCYHISTORY_V1 AS CRHST
                                                      WHERE CRHST.CURRENCYID = C1.CURRENCYID)
 WHERE cat.CATEGNAME = 'Food:Groceries'
 GROUP BY year, month
 ORDER BY year ASC, month ASC;

-- TODO: Update account names in line 31
SELECT a.accountname AS ACCOUNTNAME,
       a.initialbal + Total(t.transamount) AS BALANCE,
	a.creditlimit AS CREDITLIMIT,
       (a.initialbal + Total(t.transamount)) * Ifnull(ch.currvalue, c.baseconvrate) AS BASEBAL,
	a.creditlimit + a.initialbal + Total(t.transamount) AS AVAILABLE,
       c.pfx_symbol AS PFX_SYMBOL,
       c.sfx_symbol AS SFX_SYMBOL,
       c.group_separator AS GROUP_SEPARATOR,
       c.decimal_point AS DECIMAL_POINT
FROM
  (SELECT ca1.accountid AS ACCOUNTID,
		ca1.transdate AS TRANSDATE,
		ca1.status AS STATUS,
		(CASE WHEN ca1.transcode = 'Deposit' THEN ca1.transamount ELSE -ca1.transamount END) AS TRANSAMOUNT
   FROM checkingaccount_v1 AS ca1
   UNION ALL
   SELECT ca2.toaccountid AS ACCOUNTID,
		ca2.transdate AS TRANSDATE,
		ca2.status AS STATUS,
		ca2.totransamount AS TRANSAMOUNT
   FROM checkingaccount_v1 AS ca2
   WHERE transcode = 'Transfer') AS t
INNER JOIN accountlist_v1 AS a ON a.accountid = t.accountid
INNER JOIN currencyformats_v1 AS c ON a.currencyid = c.currencyid
LEFT JOIN currencyhistory_v1 AS ch ON ch.currencyid = c.currencyid
	AND ch.currdate = (SELECT MAX(crhst.currdate)
					   FROM currencyhistory_v1 AS crhst
					   WHERE crhst.currencyid = c.currencyid)
WHERE t.status NOT IN ('V', 'D')
  AND accountname IN ('Account1', 'Account2')
GROUP BY a.accountid
ORDER BY accountname;
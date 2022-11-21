WITH RECURSIVE categories(categid, categname, parentid) AS
    (SELECT a.categid, a.categname, a.parentid FROM category_v1 a WHERE parentid = '-1'
        UNION ALL
     SELECT c.categid, r.categname || ':' || c.categname, c.parentid
     FROM categories r, category_v1 c
	 WHERE r.categid = c.parentid
	 )
SELECT	wd_data.id				id,
	wd_data.date					AS date,
	wd_data.amount				AS amount,
	COALESCE(c.categname, '')	AS cat,
	wd_data.notes				AS notes,
	p.payeename					AS payee,
	acc.accountname				AS account,
	c.PFX_SYMBOL				AS pfx_symbol,
	c.SFX_SYMBOL				AS sfx_symbol,
	c.GROUP_SEPARATOR			AS group_separator,
	c.DECIMAL_POINT				AS decimal_point
FROM (SELECT	t1.transid		AS id,
	t1.transdate				AS date,
	t2.splittransamount		AS amount,
	t2.categid				AS catid,
	''						AS notes,
	t1.payeeid				AS payeeid,
	t1.accountid				AS accountid
	FROM splittransactions_v1 AS t2
		INNER JOIN checkingaccount_v1 AS t1	ON t1.TRANSID = t2.TRANSID
	WHERE  
	t1.transcode = "Withdrawal"
UNION ALL
SELECT	ca.transid	AS id,
	ca.transdate		AS date,
	ca.transamount	AS amount,
	ca.categid		AS catid, 
	ca.notes			AS notes,
	ca.payeeid		AS payeeid,
	ca.accountid		AS accountid
	FROM  checkingaccount_v1 AS ca
	WHERE  
		ca.transcode = "Withdrawal" AND ca.categid <>-1
) AS wd_data
LEFT JOIN accountlist_v1 AS acc ON wd_data.accountid = acc.accountid
LEFT JOIN CURRENCYFORMATS_V1 AS c ON c.CURRENCYID = acc.CURRENCYID
LEFT JOIN categories AS c ON wd_data.catid=c.categid
LEFT JOIN payee_v1 AS p ON wd_data.payeeid = p.payeeid
ORDER BY date ASC;

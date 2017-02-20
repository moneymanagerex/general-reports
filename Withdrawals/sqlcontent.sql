SELECT	t1.transid					id,
	t1.transdate					date,
	t2.splittransamount			amount,
	COALESCE(c.categname, '')
	||  ":" ||   
	COALESCE(sc.subcategname, '')	cat, 
	''							notes,
	p.payeename					payee,
	a.accountname				account
	FROM splittransactions_v1 AS t2
		INNER JOIN checkingaccount_v1 AS t1	ON t1.TRANSID = t2.TRANSID
		LEFT JOIN category_v1 c		ON t2.categid=c.categid
		LEFT JOIN subcategory_v1 sc	ON t2.subcategid= sc.subcategid
		LEFT JOIN accountlist_v1 a	ON t1.accountid = a.accountid
		LEFT JOIN payee_v1 p		ON t1.payeeid = p.payeeid
	WHERE  
		--t1.accountid in (	SELECT accountid	FROM accountlist_v1	WHERE accountname LIKE "EUR%") AND 
	t1.transcode = "Withdrawal"
UNION ALL
SELECT	ca.transid				id,
	ca.transdate					date,
	ca.transamount				amount,
	 COALESCE(c.categname, '')
	 ||  ":" || 
	 COALESCE(sc.subcategname, '')	cat,
	ca.notes						notes,
	p.payeename					payee,
	a.accountname				account
	FROM  checkingaccount_v1 AS ca
		JOIN accountlist_v1 a	ON ca.accountid = a.accountid
		LEFT JOIN payee_v1 p	ON ca.payeeid = p.payeeid
		LEFT JOIN category_v1 c	ON ca.categid=c.categid
		LEFT JOIN subcategory_v1 sc	ON ca.subcategid= sc.subcategid
	WHERE  
			--ca.accountid in (SELECT accountid FROM accountlist_v1 WHERE accountname LIKE "EUR%")	AND 
		ca.transcode = "Withdrawal" AND ca.categid <>-1
ORDER BY date
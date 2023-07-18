WITH RECURSIVE categories(categid, categname, parentid) AS
    (SELECT a.categid, a.categname, a.parentid FROM category_v1 a WHERE parentid = '-1'
        UNION ALL
     SELECT c.categid, r.categname || ':' || c.categname, c.parentid
     FROM categories r, category_v1 c
	 WHERE r.categid = c.parentid
	 )
SELECT ca.categname as category,
       total(CASE strftime('%m', date('now', 'start of month', '-11 month', 'localtime')) WHEN month THEN amount END) AS twe,
       total(CASE strftime('%m', date('now', 'start of month', '-10 month', 'localtime')) WHEN month THEN amount END) AS ele,
       total(CASE strftime('%m', date('now', 'start of month', '-9 month', 'localtime')) WHEN month THEN amount END) AS ten,
       total(CASE strftime('%m', date('now', 'start of month', '-8 month', 'localtime')) WHEN month THEN amount END) AS nin,
       total(CASE strftime('%m', date('now', 'start of month', '-7 month', 'localtime')) WHEN month THEN amount END) AS egh,
       total(CASE strftime('%m', date('now', 'start of month', '-6 month', 'localtime')) WHEN month THEN amount END) AS sev,
       total(CASE strftime('%m', date('now', 'start of month', '-5 month', 'localtime')) WHEN month THEN amount END) AS six,
       total(CASE strftime('%m', date('now', 'start of month', '-4 month', 'localtime')) WHEN month THEN amount END) AS fiv,
       total(CASE strftime('%m', date('now', 'start of month', '-3 month', 'localtime')) WHEN month THEN amount END) AS fou,
       total(CASE strftime('%m', date('now', 'start of month', '-2 month', 'localtime')) WHEN month THEN amount END) AS thr,
       total(CASE strftime('%m', date('now', 'start of month', '-1 month', 'localtime')) WHEN month THEN amount END) AS two,
       total(CASE strftime('%m', date('now', 'start of month', '-0 month', 'localtime')) WHEN month THEN amount END) AS one,
       total(CASE strftime('%m', date('now', 'start of month', '-11 month', 'localtime')) WHEN month THEN amountWithdraw END) AS WITH_twe,
       total(CASE strftime('%m', date('now', 'start of month', '-10 month', 'localtime')) WHEN month THEN amountWithdraw END) AS WITH_ele,
       total(CASE strftime('%m', date('now', 'start of month', '-9 month', 'localtime')) WHEN month THEN amountWithdraw END) AS WITH_ten,
       total(CASE strftime('%m', date('now', 'start of month', '-8 month', 'localtime')) WHEN month THEN amountWithdraw END) AS WITH_nin,
       total(CASE strftime('%m', date('now', 'start of month', '-7 month', 'localtime')) WHEN month THEN amountWithdraw END) AS WITH_egh,
       total(CASE strftime('%m', date('now', 'start of month', '-6 month', 'localtime')) WHEN month THEN amountWithdraw END) AS WITH_sev,
       total(CASE strftime('%m', date('now', 'start of month', '-5 month', 'localtime')) WHEN month THEN amountWithdraw END) AS WITH_six,
       total(CASE strftime('%m', date('now', 'start of month', '-4 month', 'localtime')) WHEN month THEN amountWithdraw END) AS WITH_fiv,
       total(CASE strftime('%m', date('now', 'start of month', '-3 month', 'localtime')) WHEN month THEN amountWithdraw END) AS WITH_fou,
       total(CASE strftime('%m', date('now', 'start of month', '-2 month', 'localtime')) WHEN month THEN amountWithdraw END) AS WITH_thr,
       total(CASE strftime('%m', date('now', 'start of month', '-1 month', 'localtime')) WHEN month THEN amountWithdraw END) AS WITH_two,
       total(CASE strftime('%m', date('now', 'start of month', '-0 month', 'localtime')) WHEN month THEN amountWithdraw END) AS WITH_one,
       total(CASE strftime('%m', date('now', 'start of month', '-11 month', 'localtime')) WHEN month THEN amountDeposit END) AS DEP_twe,
       total(CASE strftime('%m', date('now', 'start of month', '-10 month', 'localtime')) WHEN month THEN amountDeposit END) AS DEP_ele,
       total(CASE strftime('%m', date('now', 'start of month', '-9 month', 'localtime')) WHEN month THEN amountDeposit END) AS DEP_ten,
       total(CASE strftime('%m', date('now', 'start of month', '-8 month', 'localtime')) WHEN month THEN amountDeposit END) AS DEP_nin,
       total(CASE strftime('%m', date('now', 'start of month', '-7 month', 'localtime')) WHEN month THEN amountDeposit END) AS DEP_egh,
       total(CASE strftime('%m', date('now', 'start of month', '-6 month', 'localtime')) WHEN month THEN amountDeposit END) AS DEP_sev,
       total(CASE strftime('%m', date('now', 'start of month', '-5 month', 'localtime')) WHEN month THEN amountDeposit END) AS DEP_six,
       total(CASE strftime('%m', date('now', 'start of month', '-4 month', 'localtime')) WHEN month THEN amountDeposit END) AS DEP_fiv,
       total(CASE strftime('%m', date('now', 'start of month', '-3 month', 'localtime')) WHEN month THEN amountDeposit END) AS DEP_fou,
       total(CASE strftime('%m', date('now', 'start of month', '-2 month', 'localtime')) WHEN month THEN amountDeposit END) AS DEP_thr,
       total(CASE strftime('%m', date('now', 'start of month', '-1 month', 'localtime')) WHEN month THEN amountDeposit END) AS DEP_two,
       total(CASE strftime('%m', date('now', 'start of month', '-0 month', 'localtime')) WHEN month THEN amountDeposit END) AS DEP_one,
       total(amount) AS OVERALL
  FROM (
           SELECT strftime('%m', TRANSDATE) AS month,
                  CASE ifnull(c.categid, -1) WHEN -1 THEN s.categid ELSE c.categid END AS categ,
                  sum((CASE c.categid WHEN -1 THEN splittransamount ELSE transamount END) * (CASE transcode WHEN 'Withdrawal' THEN -IFNULL(CH.CURRVALUE, CF.BASECONVRATE) ELSE cf.BaseConvRate END)) as amount,
                  sum((CASE c.categid WHEN -1 THEN splittransamount ELSE transamount END) * (CASE transcode WHEN 'Withdrawal' THEN -IFNULL(CH.CURRVALUE, CF.BASECONVRATE) ELSE 0.00 END)) as amountWithdraw,
                  sum((CASE c.categid WHEN -1 THEN splittransamount ELSE transamount END) * (CASE transcode WHEN 'Withdrawal' THEN 0.00 ELSE IFNULL(CH.CURRVALUE, CF.BASECONVRATE) END)) as amountDeposit
             FROM checkingaccount_v1 c
                  LEFT JOIN
                  splittransactions_v1 s ON s.transid = c.transid
                  LEFT JOIN
                  ACCOUNTLIST_V1 AC ON AC.ACCOUNTID = c.ACCOUNTID
                  LEFT JOIN
                  currencyformats_v1 cf ON cf.currencyid = AC.currencyid
                  LEFT JOIN
                  CURRENCYHISTORY_V1 AS CH ON CH.CURRENCYID = CF.CURRENCYID AND 
                                              CH.CURRDATE = (
                                                                SELECT MAX(CRHST.CURRDATE) 
                                                                  FROM CURRENCYHISTORY_V1 AS CRHST
                                                                 WHERE CRHST.CURRENCYID = CF.CURRENCYID
                                                            )
            WHERE transcode != 'Transfer' AND 
                  c.status NOT IN ('V', 'D') AND 
				  (c.DELETEDTIME = '' OR c.DELETEDTIME IS NULL) AND
                  ac.status = 'Open' AND 
                  (date('now', 'start of month', '-11 month', 'localtime') <= transdate AND 
                   transdate < date('now', 'start of month', '+1 month', 'localtime')) 
            GROUP BY month,
                     categ
       ) AS t
       LEFT JOIN
       categories ca ON ca.categid = t.categ
 GROUP BY category
 ORDER BY category asc;

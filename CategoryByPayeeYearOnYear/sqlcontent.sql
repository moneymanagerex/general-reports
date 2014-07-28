SELECT a.payee "Payee", 
-- Columns
IFNULL (p14.total,0) "2014",
IFNULL (p13.total,0) "2013",
IFNULL (p12.total,0) "2012",
IFNULL (p11.total,0) "2011",
IFNULL (p10.total,0) "2010",
IFNULL (p09.total,0) "2009",
IFNULL (p08.total,0) "2008",
IFNULL (pTotal.total,0) "Total ('08-'14)"
-- End Columns
FROM (SELECT "payee" FROM "alldata" WHERE "category" = 'Donations' AND status not in ('V') GROUP BY "payee" ORDER BY "payee") a
-- 2014
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2014 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee") p14 on p14.payee=a.payee
-- 2013
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2013 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee") p13 on p13.payee=a.payee
-- 2012
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2012 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee") p12 on p12.payee=a.payee
-- 2011
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2011 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee") p11 on p11.payee=a.payee
-- 2010
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2010 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee") p10 on p10.payee=a.payee-- 2010
-- 2009 
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2009 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee") p09 on p09.payee=a.payee
-- 2008
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2008 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee") p08 on p08.payee=a.payee
--Grand Total
left join (SELECT "payee", SUM("amount") total FROM "alldata"
WHERE ( "category" = 'Donations'  AND "year" in (2008, 2009, 2010, 2011, 2012, 2013, 2014) AND status not in ('V')) GROUP BY "payee" ORDER BY "payee") pTotal on pTotal.payee=a.payee
UNION ALL
   SELECT  '<b>Annual Total:</b>', 
  (SELECT TOTAL(amount) total FROM alldata  WHERE year=2014 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total6 , 
  (SELECT TOTAL(amount) total FROM alldata  WHERE year=2013 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total5 , 
   (SELECT TOTAL(amount) total FROM alldata  WHERE year=2012 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total0 ,
    (SELECT TOTAL(amount) total FROM alldata  WHERE year=2011 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total1,
    (SELECT TOTAL(amount) total FROM alldata  WHERE year=2010 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total2,
    (SELECT TOTAL(amount) total FROM alldata  WHERE year=2009 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total3,
    (SELECT TOTAL(amount) total FROM alldata  WHERE year=2008 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total4, ''
;
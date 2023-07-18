SELECT a.payee "Payee", 
-- Columns
IFNULL (p23.total,0) "2023",
IFNULL (p22.total,0) "2022",
IFNULL (p21.total,0) "2021",
IFNULL (p20.total,0) "2020",
IFNULL (p19.total,0) "2019",
IFNULL (p18.total,0) "2018",
IFNULL (p17.total,0) "2017",
IFNULL (p16.total,0) "2016",
IFNULL (p15.total,0) "2015",
IFNULL (p14.total,0) "2014",
IFNULL (p13.total,0) "2013",
IFNULL (p12.total,0) "2012",
IFNULL (p11.total,0) "2011",
IFNULL (p10.total,0) "2010",
IFNULL (p09.total,0) "2009",
IFNULL (p08.total,0) "2008",
IFNULL (pTotal.total,0) "Total ('08-'23)"
-- End Columns
FROM (SELECT "payee" FROM "alldata" WHERE "category" = 'Donations' AND status not in ('V') GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) a
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations' AND "year" = 2023 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p23 on p23.payee=a.payee
--2022
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations' AND "year" = 2022 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p22 on p22.payee=a.payee
--2021
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations' AND "year" = 2021 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p21 on p21.payee=a.payee
-- 2020
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations' AND "year" = 2020 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p20 on p20.payee=a.payee
-- 2019
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2019 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p19 on p19.payee=a.payee
-- 2018
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2018 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p18 on p18.payee=a.payee
-- 2017
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2017 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p17 on p17.payee=a.payee
-- 2016
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2016 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p16 on p16.payee=a.payee
-- 2015
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2015 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p15 on p15.payee=a.payee
-- 2014
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2014 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p14 on p14.payee=a.payee
-- 2013
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2013 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p13 on p13.payee=a.payee
-- 2012
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2012 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p12 on p12.payee=a.payee
-- 2011
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2011 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p11 on p11.payee=a.payee
-- 2010
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2010 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p10 on p10.payee=a.payee-- 2010
-- 2009 
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2009 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p09 on p09.payee=a.payee
-- 2008
LEFT JOIN (SELECT "payee", SUM("amount") total FROM "alldata" WHERE ( "category" = 'Donations'  AND "year" = 2008 AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) p08 on p08.payee=a.payee
--Grand Total
left join (SELECT "payee", SUM("amount") total FROM "alldata"
WHERE ( "category" = 'Donations'  AND "year" in (2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021,2022,2023) AND status not in ('V')) GROUP BY "payee" ORDER BY "payee" COLLATE NOCASE ASC) pTotal on pTotal.payee=a.payee
UNION ALL
   SELECT  '<b>Annual Total:</b>',
  (SELECT TOTAL(amount) total FROM alldata WHERE year=2023 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total15 , 
  (SELECT TOTAL(amount) total FROM alldata WHERE year=2022 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total14 , 
  (SELECT TOTAL(amount) total FROM alldata WHERE year=2021 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total13 ,
  (SELECT TOTAL(amount) total FROM alldata WHERE year=2020 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total12 ,
  (SELECT TOTAL(amount) total FROM alldata  WHERE year=2019 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total11 , 
  (SELECT TOTAL(amount) total FROM alldata  WHERE year=2018 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total10 , 
  (SELECT TOTAL(amount) total FROM alldata  WHERE year=2017 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total9 , 
  (SELECT TOTAL(amount) total FROM alldata  WHERE year=2016 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total8 , 
  (SELECT TOTAL(amount) total FROM alldata  WHERE year=2015 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total7 , 
  (SELECT TOTAL(amount) total FROM alldata  WHERE year=2014 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total6 , 
  (SELECT TOTAL(amount) total FROM alldata  WHERE year=2013 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total5 , 
   (SELECT TOTAL(amount) total FROM alldata  WHERE year=2012 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total0 ,
    (SELECT TOTAL(amount) total FROM alldata  WHERE year=2011 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total1,
    (SELECT TOTAL(amount) total FROM alldata  WHERE year=2010 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total2,
    (SELECT TOTAL(amount) total FROM alldata  WHERE year=2009 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total3,
    (SELECT TOTAL(amount) total FROM alldata  WHERE year=2008 AND transactionType<>'Transfer' AND status <>'V' AND "category" = 'Donations') total4, ''
;
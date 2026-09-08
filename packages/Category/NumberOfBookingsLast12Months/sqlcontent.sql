WITH RECURSIVE categories(categid, categname, parentid) AS
(
    SELECT categid, categname, parentid FROM category_v1 WHERE parentid = -1
    UNION ALL
    SELECT c.categid, r.categname || ':' || c.categname, c.parentid
      FROM categories r JOIN category_v1 c ON c.parentid = r.categid
),
bookings AS
(
    SELECT strftime('%m', c.transdate) AS month,
           CASE WHEN s.categid IS NULL THEN c.categid ELSE s.categid END AS categ,
           CASE WHEN c.transcode = 'Withdrawal' THEN 1 ELSE 0 END AS withdrawals,
           CASE WHEN c.transcode = 'Deposit' THEN 1 ELSE 0 END AS deposits
      FROM checkingaccount_v1 c
      LEFT JOIN splittransactions_v1 s ON s.transid = c.transid
      JOIN accountlist_v1 ac ON ac.accountid = c.accountid
     WHERE c.transcode IN ('Withdrawal', 'Deposit')
       AND c.status NOT IN ('V', 'D')
       AND (c.deletedtime = '' OR c.deletedtime IS NULL)
       AND ac.status = 'Open'
       AND date('now', 'start of month', '-11 month', 'localtime') <= c.transdate
       AND c.transdate < date('now', 'start of month', '+1 month', 'localtime')
),
monthly AS
(
    SELECT month, categ, count(*) AS booking_count,
           sum(withdrawals) AS withdrawal_count, sum(deposits) AS deposit_count
      FROM bookings GROUP BY month, categ
)
SELECT ca.categname AS category,
       total(CASE strftime('%m', date('now','start of month','-11 month','localtime')) WHEN month THEN booking_count END) AS twe,
       total(CASE strftime('%m', date('now','start of month','-10 month','localtime')) WHEN month THEN booking_count END) AS ele,
       total(CASE strftime('%m', date('now','start of month','-9 month','localtime')) WHEN month THEN booking_count END) AS ten,
       total(CASE strftime('%m', date('now','start of month','-8 month','localtime')) WHEN month THEN booking_count END) AS nin,
       total(CASE strftime('%m', date('now','start of month','-7 month','localtime')) WHEN month THEN booking_count END) AS egh,
       total(CASE strftime('%m', date('now','start of month','-6 month','localtime')) WHEN month THEN booking_count END) AS sev,
       total(CASE strftime('%m', date('now','start of month','-5 month','localtime')) WHEN month THEN booking_count END) AS six,
       total(CASE strftime('%m', date('now','start of month','-4 month','localtime')) WHEN month THEN booking_count END) AS fiv,
       total(CASE strftime('%m', date('now','start of month','-3 month','localtime')) WHEN month THEN booking_count END) AS fou,
       total(CASE strftime('%m', date('now','start of month','-2 month','localtime')) WHEN month THEN booking_count END) AS thr,
       total(CASE strftime('%m', date('now','start of month','-1 month','localtime')) WHEN month THEN booking_count END) AS two,
       total(CASE strftime('%m', date('now','start of month','0 month','localtime')) WHEN month THEN booking_count END) AS one,
       total(CASE strftime('%m', date('now','start of month','-11 month','localtime')) WHEN month THEN withdrawal_count END) AS WITH_twe,
       total(CASE strftime('%m', date('now','start of month','-10 month','localtime')) WHEN month THEN withdrawal_count END) AS WITH_ele,
       total(CASE strftime('%m', date('now','start of month','-9 month','localtime')) WHEN month THEN withdrawal_count END) AS WITH_ten,
       total(CASE strftime('%m', date('now','start of month','-8 month','localtime')) WHEN month THEN withdrawal_count END) AS WITH_nin,
       total(CASE strftime('%m', date('now','start of month','-7 month','localtime')) WHEN month THEN withdrawal_count END) AS WITH_egh,
       total(CASE strftime('%m', date('now','start of month','-6 month','localtime')) WHEN month THEN withdrawal_count END) AS WITH_sev,
       total(CASE strftime('%m', date('now','start of month','-5 month','localtime')) WHEN month THEN withdrawal_count END) AS WITH_six,
       total(CASE strftime('%m', date('now','start of month','-4 month','localtime')) WHEN month THEN withdrawal_count END) AS WITH_fiv,
       total(CASE strftime('%m', date('now','start of month','-3 month','localtime')) WHEN month THEN withdrawal_count END) AS WITH_fou,
       total(CASE strftime('%m', date('now','start of month','-2 month','localtime')) WHEN month THEN withdrawal_count END) AS WITH_thr,
       total(CASE strftime('%m', date('now','start of month','-1 month','localtime')) WHEN month THEN withdrawal_count END) AS WITH_two,
       total(CASE strftime('%m', date('now','start of month','0 month','localtime')) WHEN month THEN withdrawal_count END) AS WITH_one,
       total(CASE strftime('%m', date('now','start of month','-11 month','localtime')) WHEN month THEN deposit_count END) AS DEP_twe,
       total(CASE strftime('%m', date('now','start of month','-10 month','localtime')) WHEN month THEN deposit_count END) AS DEP_ele,
       total(CASE strftime('%m', date('now','start of month','-9 month','localtime')) WHEN month THEN deposit_count END) AS DEP_ten,
       total(CASE strftime('%m', date('now','start of month','-8 month','localtime')) WHEN month THEN deposit_count END) AS DEP_nin,
       total(CASE strftime('%m', date('now','start of month','-7 month','localtime')) WHEN month THEN deposit_count END) AS DEP_egh,
       total(CASE strftime('%m', date('now','start of month','-6 month','localtime')) WHEN month THEN deposit_count END) AS DEP_sev,
       total(CASE strftime('%m', date('now','start of month','-5 month','localtime')) WHEN month THEN deposit_count END) AS DEP_six,
       total(CASE strftime('%m', date('now','start of month','-4 month','localtime')) WHEN month THEN deposit_count END) AS DEP_fiv,
       total(CASE strftime('%m', date('now','start of month','-3 month','localtime')) WHEN month THEN deposit_count END) AS DEP_fou,
       total(CASE strftime('%m', date('now','start of month','-2 month','localtime')) WHEN month THEN deposit_count END) AS DEP_thr,
       total(CASE strftime('%m', date('now','start of month','-1 month','localtime')) WHEN month THEN deposit_count END) AS DEP_two,
       total(CASE strftime('%m', date('now','start of month','0 month','localtime')) WHEN month THEN deposit_count END) AS DEP_one,
       total(booking_count) AS OVERALL
  FROM monthly t LEFT JOIN categories ca ON ca.categid = t.categ
 GROUP BY category ORDER BY category ASC;

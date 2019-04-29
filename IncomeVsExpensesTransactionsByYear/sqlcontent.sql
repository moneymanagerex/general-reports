SELECT tx_yr_data.yeartype as YEARTYPE,
	tx_yr_data.year as YEAR,
       sum(tx_yr_data.income) AS INCOME,
       sum(tx_yr_data.expense) AS EXPENSE
  FROM (
           SELECT yeartype as yeartype,
               CASE yeartype
               WHEN 'FIN_YEAR'
                   THEN CASE WHEN ( (CAST (strftime('%m', transdate) AS INTEGER) < fin_yr_mth) OR
                                                              (CAST (strftime('%m', transdate) AS INTEGER) = fin_yr_mth AND
                                                               CAST (strftime('%d', transdate) AS INTEGER) < fin_yr_day) )
                       THEN tx_data.year - 1
                       ELSE tx_data.year
                       END
                   ELSE tx_data.year
                   END AS YEAR,
                  tx_data.income AS income,
                  tx_data.expense AS expense
             FROM (/* change SELECT 'YEAR' to SELECT 'FIN_YEAR' if you want financial years based on settings for financial year start month & day from MMEX options, keep as SELECT 'YEAR' for normal years Jan-01 to Dec-31 */
                      SELECT 'YEAR' AS yeartype, -- values are 'YEAR' or 'FIN_YEAR'
                             CA.transdate AS transdate,
                             CAST (strftime('%Y', transdate) AS INTEGER) AS year,
                             CASE WHEN ca.transcode = 'Deposit' THEN ROUND(CA.TRANSAMOUNT * cf.baseconvrate, 2) ELSE 0 END AS income,
                             CASE WHEN ca.transcode = 'Withdrawal' THEN ROUND(CA.TRANSAMOUNT * cf.baseconvrate, 2) ELSE 0 END AS expense,
                             CAST ( (
                                 SELECT it1.infovalue
                                   FROM infotable_v1 AS it1
                                  WHERE IT1.infoname = 'FINANCIAL_YEAR_START_MONTH'
                             )
                             AS INTERGER) AS fin_yr_mth,
                             CAST ( (
                                 SELECT it2.infovalue
                                   FROM infotable_v1 AS it2
                                  WHERE IT2.infoname = 'FINANCIAL_YEAR_START_DAY'
                             )
                             AS INTEGER) AS fin_yr_day
                        FROM checkingaccount_v1 AS ca
                             INNER JOIN
                             accountlist_v1 AS acc ON acc.accountid = ca.accountid
                             INNER JOIN
                             currencyformats_v1 AS CF ON cf.currencyid = acc.currencyid
                       WHERE ca.status NOT IN ('D', 'V') AND
                             ca.transcode <> 'Transfer' AND
                             strftime('%Y', transdate) IN ('2015', '2016', '2017', '2018', '2019', '2020') -- change the years to those you're interested in, note the yeartype flag above. 
                  )
                  AS tx_data
       )
       tx_yr_data
 GROUP BY tx_yr_data.year, tx_yr_data.yeartype
 ORDER BY tx_yr_data.year ASC;

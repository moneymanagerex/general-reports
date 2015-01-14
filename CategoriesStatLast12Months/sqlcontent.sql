select 
case t.subcateg when -1 then ca.categname else ca.categname ||':'||sc.subcategname end category
, t.transid, t.categ
, total( case strftime('%m', date('now', 'start of month','-11 month','localtime')) when month then amount end ) as twe
, total( case strftime('%m', date('now', 'start of month','-10 month','localtime')) when month then amount end ) as ele
, total( case strftime('%m', date('now', 'start of month','-9 month','localtime')) when month then amount end ) as ten
, total( case strftime('%m', date('now', 'start of month','-8 month','localtime')) when month then amount end ) as nin
, total( case strftime('%m', date('now', 'start of month','-7 month','localtime')) when month then amount end ) as egh
, total( case strftime('%m', date('now', 'start of month','-6 month','localtime')) when month then amount end ) as sev
, total( case strftime('%m', date('now', 'start of month','-5 month','localtime')) when month then amount end ) as six
, total( case strftime('%m', date('now', 'start of month','-4 month','localtime')) when month then amount end ) as fiv
, total( case strftime('%m', date('now', 'start of month','-3 month','localtime')) when month then amount end ) as fou
, total( case strftime('%m', date('now', 'start of month','-2 month','localtime')) when month then amount end ) as thr
, total( case strftime('%m', date('now', 'start of month','-1 month','localtime')) when month then amount end ) as two
, total( case strftime('%m', date('now', 'start of month','-0 month','localtime')) when month then amount end ) as one
, total(amount) as OVERALL
from(
    select 
         strftime('%m', TRANSDATE) as month
	 , c.transid, cf.BaseConvRate
	    , c.accountid, c.transcode
	    , case ifnull(c.categid, -1) when -1 then s.categid else c.categid end as categ
	    , case ifnull(c.subcategid,-1) when -1 then ifnull(s.subcategid,-1) else ifnull(c.subcategid,-1) end as subcateg
	    , c.payeeid
	    , sum((case c.categid when -1 then  splittransamount else  transamount  end) 
	        * (case transcode when 'Withdrawal' then - cf.BaseConvRate else cf.BaseConvRate end)
            ) amount
    from checkingaccount_v1 c
    left join splittransactions_v1 s on s.transid=c.transid
    left join ACCOUNTLIST_V1 AC on AC.ACCOUNTID = c.ACCOUNTID
    left join currencyformats_v1 cf on cf.currencyid=AC.currencyid
    where transcode != 'Transfer'
    and c.status !='V'
    and ac.status !='Closed'
    and (date('now', 'start of month','-11 month','localtime') <= transdate
        and transdate < date('now', 'start of month','+1 month','localtime'))
    group by month, categ, subcateg
    ) t 
    left join category_v1 ca on ca.categid=t.categ
    left join subcategory_v1 sc on sc.categid=t.categ and sc.subcategid=t.subcateg

group by category
order by category
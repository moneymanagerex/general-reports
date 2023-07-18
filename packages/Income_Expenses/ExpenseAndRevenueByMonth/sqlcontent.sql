select 
    'month' as periode_name,
    periode,
    sum(Deposit) as Deposit,
    sum(Withdrawal) as Withdrawal,
    round(sum(Deposit) + sum(Withdrawal),2) as Total,
    (
        (SELECT sum(initialbal) FROM accountlist_V1)
        +
	(
	    SELECT sum(totransamount) FROM checkingaccount_V1
	    where
                TRANSDATE <= date('now', 'start of month','-4 year','localtime')
	)
    ) as initialbal
from (  
    select 
        strftime('%Y-%m', TRANSDATE) as periode,
        case
            when transcode = 'Deposit' then transamount
            else 0
        end as Deposit,
        case
          when transcode = 'Withdrawal' then -transamount
          else 0
        end as Withdrawal
        --,*
    from
        checkingaccount_V1
    where
        TRANSDATE > date('now', 'start of month','-4 year','localtime')
        and status <>'V'
)
group by periode
order by periode asc

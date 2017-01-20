select
    'month' as periode_name,
    periode,
    sum(Deposit) as Deposit,
    sum(Withdrawal) as Withdrawal,
	  sum(Transfer) as Transfer,
    round(sum(Deposit) + sum(Withdrawal) + sum(Transfer),2) as Total,
    (SELECT sum(initialbal) FROM accountlist_V1) as initialbal
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
        end as Withdrawal,
    		case
    			when transcode = 'Transfer' and toaccountid in (SELECT accountid FROM accountlist_V1 where accounttype ='Loan') then -transamount
    			when transcode = 'Transfer' and accountid in (SELECT accountid FROM accountlist_V1 where accounttype ='Loan') then transamount
    			else 0
		end as Transfer
        --,*
    from
        checkingaccount_V1
    where
    /*    TRANSDATE > date('now', 'start of month','-5 year','localtime') and */
        status <>'V'
)
group by periode
order by periode asc

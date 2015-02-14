select 
  year,
  sum(Deposit) as Deposit,
  sum(Withdrawal) as Withdrawal,
  round(sum(Deposit) + sum(Withdrawal),2) as Total
from (  
  select 
    strftime('%Y', TRANSDATE) as year,
    case
      when transcode = 'Deposit' then totransamount
      else 0
    end as Deposit,
    case
      when transcode = 'Deposit' then 0
      else totransamount
    end as Withdrawal
    --,*
  from
    checkingaccount_V1
)
group by year
order by year asc
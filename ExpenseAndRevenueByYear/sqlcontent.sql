select 
    'year' as periode_name,
    periode,
  sum(Deposit) as Deposit,
  sum(Withdrawal) as Withdrawal,
  round(sum(Deposit) + sum(Withdrawal),2) as Total,
    (SELECT sum(initialbal) FROM accountlist_V1) as initialbal
from (  
  select 
    strftime('%Y', TRANSDATE) as periode,
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
  where status <>'V'
)
group by periode
order by periode asc

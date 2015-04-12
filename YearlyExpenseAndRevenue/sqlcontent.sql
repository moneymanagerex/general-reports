select 
    periode_month, 
    sum(Total) Total, 
    sum(Total_n1) Total_n1, 
    sum(Total_n2) Total_n2,
    sum(Total_n3) Total_n3,
    sum(Total_n4) Total_n4,
    strftime('%Y',date('now', 'start of year','localtime')) name_n0,
    strftime('%Y',date('now', 'start of year','-1 year','localtime')) name_n1,
    strftime('%Y',date('now', 'start of year','-2 year','localtime')) name_n2,
    strftime('%Y',date('now', 'start of year','-3 year','localtime')) name_n3,
    strftime('%Y',date('now', 'start of year','-4 year','localtime')) name_n4
from (
    select 
        periode_month,
        case
            when periode_year = strftime('%Y',date('now', 'start of year','localtime'))
      then round(sum(Deposit) + sum(Withdrawal),2) 
      else 0
        end as Total,
        case
            when periode_year = strftime('%Y',date('now', 'start of year','-1 year','localtime'))
      then round(sum(Deposit) + sum(Withdrawal),2) 
      else 0
        end as Total_n1,
        case
            when periode_year = strftime('%Y',date('now', 'start of year','-2 year','localtime'))
      then round(sum(Deposit) + sum(Withdrawal),2) 
      else 0
        end as Total_n2,
        case
            when periode_year = strftime('%Y',date('now', 'start of year','-3 year','localtime'))
      then round(sum(Deposit) + sum(Withdrawal),2) 
      else 0
        end as Total_n3,
        case
            when periode_year = strftime('%Y',date('now', 'start of year','-4 year','localtime'))
      then round(sum(Deposit) + sum(Withdrawal),2) 
      else 0
        end as Total_n4
    from (  
        select 
            strftime('%Y', TRANSDATE) as periode_year,
            strftime('%m', TRANSDATE) as periode_month,
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
            TRANSDATE > date('now', 'start of year','-4 year','localtime')
             and status <>'V'
    )
    group by periode_year,periode_month
    order by periode_year,periode_month asc
)
group by periode_month
order by periode_month asc;
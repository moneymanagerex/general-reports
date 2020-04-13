select msg.me as info, 
case msg.id 
when 1 then qd.quitdate 
when 2 then round(julianday('now') - julianday(qd.quitdate)) 
when 3 then round(julianday('now') - julianday(qd.quitdate)) *qd.sigperday
when 4 then round(julianday('now') - julianday(qd.quitdate)) *qd.sigperday*qd.w  
when 5 then round((julianday('now') - julianday(qd.quitdate)) *qd.sigperday*7/24/60)  
when 6 then round((julianday('now') - julianday(qd.quitdate)) *qd.sigperday/20*qd.cost)  
end as result 
from 
(select 'The date when I quit smoking' me, 1 as id
union all select 'Since then, it took days:', 2
union all select 'I have not smoked a cigarettes:', 3
union all select 'I have not absorbed the nicotine gram:', 4
union all select 'I''ll live an additional days', 5
union all select 'I save on cigarettes:', 6
) msg
left join (select '2008-11-01' as quitdate --The date when I quit smoking
, 20 as sigperday --How many cigarettes smoked per day
, 50 as cost -- Cost of one pack of cigarettes
, 0.001 as w -- mg of nikotine per sigaret
) qd 
select a.ACCOUNTNAME,	(select a.INITIALBAL + total(t.TRANSAMOUNT)
		from
		(select ACCOUNTID, STATUS,
			(case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
			from CHECKINGACCOUNT_V1
			where  TRANSDATE < date('now', 'start of month', '-12 month')
			union all
			select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
			from CHECKINGACCOUNT_V1
			where TRANSCODE = 'Transfer' and TRANSDATE < date('now', 'start of month', '-12 month')
		) as t
		where  t.ACCOUNTID = a.ACCOUNTID and t.STATUS <> 'V'
	) as Balance12ago,

	(select a.INITIALBAL + total(t.TRANSAMOUNT)
		from
		(select ACCOUNTID, STATUS,
			(case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
			from CHECKINGACCOUNT_V1
			where  TRANSDATE < date('now', 'start of month', '-11 month')
			union all
			select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
			from CHECKINGACCOUNT_V1
			where TRANSCODE = 'Transfer' and TRANSDATE < date('now', 'start of month', '-11 month')
		) as t
		where  t.ACCOUNTID = a.ACCOUNTID and t.STATUS <> 'V'
	) as Balance11ago,

	(select a.INITIALBAL + total(t.TRANSAMOUNT)
		from
		(select ACCOUNTID, STATUS,
			(case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
			from CHECKINGACCOUNT_V1
			where  TRANSDATE < date('now', 'start of month', '-10 month')
			union all
			select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
			from CHECKINGACCOUNT_V1
			where TRANSCODE = 'Transfer' and TRANSDATE < date('now', 'start of month', '-10 month')
		) as t
		where  t.ACCOUNTID = a.ACCOUNTID and t.STATUS <> 'V'
	) as Balance10ago,

	(select a.INITIALBAL + total(t.TRANSAMOUNT)
		from
		(select ACCOUNTID, STATUS,
			(case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
			from CHECKINGACCOUNT_V1
			where  TRANSDATE < date('now', 'start of month', '-9 month')
			union all
			select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
			from CHECKINGACCOUNT_V1
			where TRANSCODE = 'Transfer' and TRANSDATE < date('now', 'start of month', '-9 month')
		) as t
		where  t.ACCOUNTID = a.ACCOUNTID and t.STATUS <> 'V'
	) as Balance9ago,

	(select a.INITIALBAL + total(t.TRANSAMOUNT)
		from
		(select ACCOUNTID, STATUS,
			(case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
			from CHECKINGACCOUNT_V1
			where  TRANSDATE < date('now', 'start of month', '-8 month')
			union all
			select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
			from CHECKINGACCOUNT_V1
			where TRANSCODE = 'Transfer' and TRANSDATE < date('now', 'start of month', '-8 month')
		) as t
		where  t.ACCOUNTID = a.ACCOUNTID and t.STATUS <> 'V'
	) as Balance8ago,

	(select a.INITIALBAL + total(t.TRANSAMOUNT)
		from
		(select ACCOUNTID, STATUS,
			(case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
			from CHECKINGACCOUNT_V1
			where  TRANSDATE < date('now', 'start of month', '-7 month')
			union all
			select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
			from CHECKINGACCOUNT_V1
			where TRANSCODE = 'Transfer' and TRANSDATE < date('now', 'start of month', '-7 month')
		) as t
		where  t.ACCOUNTID = a.ACCOUNTID and t.STATUS <> 'V'
	) as Balance7ago,

	(select a.INITIALBAL + total(t.TRANSAMOUNT)
		from
		(select ACCOUNTID, STATUS,
			(case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
			from CHECKINGACCOUNT_V1
			where  TRANSDATE < date('now', 'start of month', '-6 month')
			union all
			select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
			from CHECKINGACCOUNT_V1
			where TRANSCODE = 'Transfer' and TRANSDATE < date('now', 'start of month', '-6 month')
		) as t
		where  t.ACCOUNTID = a.ACCOUNTID and t.STATUS <> 'V'
	) as Balance6ago,

	(select a.INITIALBAL + total(t.TRANSAMOUNT)
		from
		(select ACCOUNTID, STATUS,
			(case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
			from CHECKINGACCOUNT_V1
			where  TRANSDATE < date('now', 'start of month', '-5 month')
			union all
			select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
			from CHECKINGACCOUNT_V1
			where TRANSCODE = 'Transfer' and TRANSDATE < date('now', 'start of month', '-5 month')
		) as t
		where  t.ACCOUNTID = a.ACCOUNTID and t.STATUS <> 'V'
	) as Balance5ago,

	(select a.INITIALBAL + total(t.TRANSAMOUNT)
		from
		(select ACCOUNTID, STATUS,
			(case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
			from CHECKINGACCOUNT_V1
			where  TRANSDATE < date('now', 'start of month', '-4 month')
			union all
			select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
			from CHECKINGACCOUNT_V1
			where TRANSCODE = 'Transfer' and TRANSDATE < date('now', 'start of month', '-4 month')
		) as t
		where  t.ACCOUNTID = a.ACCOUNTID and t.STATUS <> 'V'
	) as Balance4ago,
	(select a.INITIALBAL + total(t.TRANSAMOUNT)
		from
		(select ACCOUNTID, STATUS,
			(case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
			from CHECKINGACCOUNT_V1
			where  TRANSDATE < date('now', 'start of month', '-3 month')
			union all
			select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
			from CHECKINGACCOUNT_V1
			where TRANSCODE = 'Transfer' and TRANSDATE < date('now', 'start of month', '-3 month')
		) as t
		where  t.ACCOUNTID = a.ACCOUNTID and t.STATUS <> 'V'
	) as Balance3ago,

	(select a.INITIALBAL + total(t.TRANSAMOUNT)
		from
		(select ACCOUNTID, STATUS,
			(case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
			from CHECKINGACCOUNT_V1
			where  TRANSDATE < date('now', 'start of month', '-2 month')
			union all
			select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
			from CHECKINGACCOUNT_V1
			where TRANSCODE = 'Transfer' and TRANSDATE < date('now', 'start of month', '-2 month')
		) as t
		where  t.ACCOUNTID = a.ACCOUNTID and t.STATUS <> 'V'
	) as Balance2ago,

	(select a.INITIALBAL + total(t.TRANSAMOUNT)
		from
		(select ACCOUNTID, STATUS,
			(case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
			from CHECKINGACCOUNT_V1
			where  TRANSDATE < date('now', 'start of month', '-1 month')
			union all
			select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
			from CHECKINGACCOUNT_V1
			where TRANSCODE = 'Transfer' and TRANSDATE < date('now', 'start of month', '-1 month')
		) as t
		where  t.ACCOUNTID = a.ACCOUNTID and t.STATUS <> 'V'
	) as Balance1ago,

	(select a.INITIALBAL + total(t.TRANSAMOUNT)
		from
		(select ACCOUNTID, STATUS,
			(case when TRANSCODE = 'Deposit' then TRANSAMOUNT else -TRANSAMOUNT end) as TRANSAMOUNT
			from CHECKINGACCOUNT_V1
			union all
			select TOACCOUNTID, STATUS, TOTRANSAMOUNT 
			from CHECKINGACCOUNT_V1
			where TRANSCODE = 'Transfer'
		) as t
		where  t.ACCOUNTID = a.ACCOUNTID and t.STATUS <> 'V'
	) as BalanceNow

from ACCOUNTLIST_V1 as a
where a.STATUS = 'Open' and a.FAVORITEACCT = 'TRUE'
group by a.ACCOUNTNAME
order by BalanceNow desc limit 8;

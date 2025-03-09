select
stock.stockname
, stock.symbol
, txn.transdate
, txn.transcode
, trade.*

from shareinfo_v1 as trade
join checkingaccount_v1 as txn on (trade.checkingaccountid = txn.transid)
join translink_v1 as link on (trade.checkingaccountid = link.checkingaccountid and link.linktype = 'Stock')
join stock_v1 as stock on (link.linkrecordid = stock.stockid)

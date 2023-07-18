SELECT A.reftype AS Type, A.refid AS Nr,
C.StartDate||' | '||C.AssetName||' | '
||(SELECT pfx_symbol FROM currencyformats_v1 WHERE currencyid = (SELECT infovalue FROM infotable_v1 WHERE INFONAME = 'BASECURRENCYID') )
||round(C.Value, 2)
||(SELECT sfx_symbol FROM currencyformats_v1 WHERE currencyid = (SELECT infovalue FROM infotable_v1 WHERE INFONAME = 'BASECURRENCYID') ) AS Reference,
A.description AS Description, A.filename AS File,
(SELECT infovalue FROM infotable_v1 WHERE infoname = 'ATTACHMENTSFOLDER:Win' COLLATE NOCASE) AS BasePath,
'\'||A.reftype||'\'||A.filename AS FilePath, '' AS BasepathLUA
FROM attachment_v1 A INNER JOIN assets_v1 C ON C.assetid = A.refid
WHERE A.reftype = "Asset"

UNION ALL

SELECT A.reftype AS Type, A.refid AS Nr,
C.AccountType||' | '||C.AccountName AS Reference,
A.description AS Description, A.filename AS File,
(SELECT infovalue FROM infotable_v1 WHERE infoname = 'ATTACHMENTSFOLDER:Win' COLLATE NOCASE) AS BasePath,
'\'||A.reftype||'\'||A.filename AS FilePath, '' AS BasepathLUA
FROM attachment_v1 A INNER JOIN accountlist_v1 C ON C.accountid = A.refid
WHERE A.reftype like "Bank%Account"

UNION ALL

SELECT A.reftype AS Type, A.refid AS Nr,
AC.AccountName||' | '|| CURR.pfx_symbol||round(C.Transamount, 2) ||CURR.sfx_symbol ||' | Next ->'|| C.nextoccurrencedate AS Reference,
A.description AS Description, A.filename AS File,
(SELECT infovalue FROM infotable_v1 WHERE infoname = 'ATTACHMENTSFOLDER:Win' COLLATE NOCASE) AS BasePath,
'\'||A.reftype||'\'||A.filename AS FilePath, '' AS BasepathLUA
FROM attachment_v1 A
    INNER JOIN billsdeposits_v1 C ON C.bdid = A.refid
    INNER JOIN accountlist_v1 AC ON C.accountid = AC.accountid
    INNER JOIN currencyformats_v1 CURR ON AC.currencyid = CURR.currencyid
WHERE A.reftype = "RepeatingTransaction"

UNION ALL

SELECT A.reftype AS Type, A.refid AS Nr, C.PayeeName AS Reference, A.description AS Description, A.filename AS File,
(SELECT infovalue FROM infotable_v1 WHERE infoname = 'ATTACHMENTSFOLDER:Win' COLLATE NOCASE) AS BasePath,
'\'||A.reftype||'\'||A.filename AS FilePath, '' AS BasepathLUA
FROM attachment_v1 A INNER JOIN payee_v1 C ON C.payeeid = A.refid
WHERE A.reftype = "Payee"

UNION ALL

SELECT A.reftype AS Type, A.refid AS Nr,
C.PurchaseDate||' | '||C.StockName||' - '||C.Symbol||' | '||C.NumShares||' | '
||(SELECT pfx_symbol FROM currencyformats_v1 WHERE currencyid = (SELECT infovalue FROM infotable_v1 WHERE INFONAME = 'BASECURRENCYID') )
||round(C.PurchasePrice, 2)
||(SELECT sfx_symbol FROM currencyformats_v1 WHERE currencyid = (SELECT infovalue FROM infotable_v1 WHERE INFONAME = 'BASECURRENCYID') ) AS Reference,
A.description AS Description, A.filename AS File,
(SELECT infovalue FROM infotable_v1 WHERE infoname = 'ATTACHMENTSFOLDER:Win' COLLATE NOCASE) AS BasePath,
'\'||A.reftype||'\'||A.filename AS FilePath, '' AS BasepathLUA
FROM attachment_v1 A INNER JOIN stock_v1 C ON C.stockid = A.refid
WHERE A.reftype = "Stock"

UNION ALL

SELECT A.reftype AS Type, A.refid AS Nr,
C.transdate||' | '||AC.AccountName||' | '|| CURR.pfx_symbol||round(C.Transamount, 2) ||CURR.sfx_symbol AS Reference,
A.description AS Description, A.filename AS File,
(SELECT infovalue FROM infotable_v1 WHERE infoname = 'ATTACHMENTSFOLDER:Win' COLLATE NOCASE) AS BasePath,
'\'||A.reftype||'\'||A.filename AS FilePath, '' AS BasepathLUA
FROM attachment_v1 A
    INNER JOIN checkingaccount_v1 C ON C.transid = A.refid
    INNER JOIN accountlist_v1 AC ON C.accountid = AC.accountid
    INNER JOIN currencyformats_v1 CURR ON AC.currencyid = CURR.currencyid
WHERE A.reftype = "Transaction"

ORDER BY A.reftype, A.refid,A.filename
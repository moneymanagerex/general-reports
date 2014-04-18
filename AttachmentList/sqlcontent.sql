SELECT A.reftype AS Type, A.refid AS Nr,
C.transdate||' | '||AC.AccountName||' | '|| CURR.pfx_symbol||round(C.Transamount, 2) ||CURR.sfx_symbol AS Reference,
A.description AS Description, A.filename AS File,
(SELECT infovalue FROM infotable_v1 WHERE infoname = 'ATTACHMENTSFOLDER:Win' COLLATE NOCASE) AS BasePath,
'\'||A.reftype||'\'||A.filename AS FilePath, '' AS BasepathLUA
FROM attachment_v1 A
    INNER JOIN checkingaccount_v1 C ON C.transid = A.refid
    INNER JOIN accountlist_v1 AC ON C.accountid = AC.accountid
    INNER JOIN currencyformats_v1 CURR ON AC.currencyid = CURR.currencyid
ORDER BY A.reftype,A.refid,A.filename;